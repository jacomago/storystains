use std::str::FromStr;

use actix_web::{web, HttpResponse, ResponseError};
use actix_web_lab::__reexports::futures_util::TryFutureExt;
use anyhow::Context;
use reqwest::StatusCode;
use sqlx::PgPool;

use crate::api::{
    emotions::model::emotions,
    error_chain_fmt,
    reviews::ReviewSlug,
    shared::put_block::{block_non_creator, BlockError},
    LongFormText, UserId,
};

use super::{
    db::{
        create_review_emotion, read_review_emotion, retreive_all_emotions, update_review_emotion,
    },
    model::{
        Emotion, EmotionPosition, NewReviewEmotion, ReviewEmotionData, ReviewEmotionResponse,
        UpdateReviewEmotion,
    },
};

/// API for getting a list of all emotions
#[tracing::instrument(name = "Getting emotions", skip(), fields())]
pub async fn get_emotions() -> Result<HttpResponse, actix_web::Error> {
    Ok(HttpResponse::Ok().json(serde_json::json!({ "emotions": emotions() })))
}

/// Review Error expresses problems that can happen during the evaluation of the reviews api.
#[derive(thiserror::Error)]
pub enum ReviewEmotionError {
    #[error("{0}")]
    /// Validation error i.e. empty title
    ValidationError(String),
    #[error("{0}")]
    /// Not Allowed Error i.e. user editing another users review
    NotAllowedError(String),
    #[error(transparent)]
    // TODO make a more general db error and separate from no data
    /// Nothing found from the database
    NoDataError(#[from] sqlx::Error),
    /// Any other error that could happen
    #[error(transparent)]
    UnexpectedError(#[from] anyhow::Error),
}

impl std::fmt::Debug for ReviewEmotionError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        error_chain_fmt(self, f)
    }
}

impl ResponseError for ReviewEmotionError {
    fn status_code(&self) -> StatusCode {
        match self {
            ReviewEmotionError::ValidationError(_) => StatusCode::BAD_REQUEST,
            ReviewEmotionError::NotAllowedError(_) => StatusCode::FORBIDDEN,
            ReviewEmotionError::NoDataError(_) => StatusCode::NOT_FOUND,
            ReviewEmotionError::UnexpectedError(_) => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}

impl From<BlockError> for ReviewEmotionError {
    fn from(e: BlockError) -> Self {
        match e {
            BlockError::NoDataError(d) => ReviewEmotionError::NoDataError(d),
            BlockError::NotAllowedError(d) => ReviewEmotionError::NotAllowedError(d),
        }
    }
}

/// Input of format for data of a review's emotion
#[derive(serde::Deserialize)]
pub struct PostReviewEmotionData {
    emotion: String,
    position: i32,
    notes: Option<String>,
}

/// Input format for posting a review's emotion
#[derive(serde::Deserialize)]
pub struct PostReviewEmotion {
    review_emotion: PostReviewEmotionData,
}

impl TryFrom<PostReviewEmotionData> for NewReviewEmotion {
    type Error = String;
    fn try_from(value: PostReviewEmotionData) -> Result<Self, Self::Error> {
        let emotion: Emotion = Emotion::from_str(&value.emotion).map_err(|e| e.to_string())?;
        let notes = match &value.notes {
            Some(t) => Some(LongFormText::parse(t.to_string())?),
            None => None,
        };
        let position = EmotionPosition::parse(value.position)?;
        Ok(Self {
            emotion,
            position,
            notes,
        })
    }
}

/// API for adding a new review
#[tracing::instrument(
    name = "Adding a new review emotion",
    skip(pool, json),
    fields(
        emotion = %json.review_emotion.emotion,
        position = %json.review_emotion.position,
    )
)]
pub async fn post_review_emotion(
    user_id: web::ReqData<UserId>,
    slug: web::Path<String>,
    json: web::Json<PostReviewEmotion>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ReviewEmotionError> {
    let user_id = user_id.into_inner();
    let slug = ReviewSlug::parse(slug.to_string()).map_err(ReviewEmotionError::ValidationError)?;

    block_non_creator(&slug, user_id, &pool.get_ref()).await?;
    let new_review_emotion = json
        .0
        .review_emotion
        .try_into()
        .map_err(ReviewEmotionError::ValidationError)?;
    let stored = create_review_emotion(&slug, &new_review_emotion, pool.get_ref())
        .await
        .context("Failed to store new review.")?;
    Ok(HttpResponse::Ok().json(ReviewEmotionResponse {
        review_emotion: ReviewEmotionData::from(stored),
    }))
}

/// API for getting a review_emotion, takes slug as id
#[tracing::instrument(
    name = "Getting a review_emotion",
    skip(pool),
    fields(
        slug = %slug,
        position = %position
    )
)]
pub async fn get_review_emotion(
    slug: web::Path<String>,
    position: web::Path<i32>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ReviewEmotionError> {
    let slug = ReviewSlug::parse(slug.to_string()).map_err(ReviewEmotionError::ValidationError)?;
    let position =
        EmotionPosition::parse(*position).map_err(ReviewEmotionError::ValidationError)?;
    let stored = read_review_emotion(&slug, position, pool.get_ref())
        .await
        .map_err(ReviewEmotionError::NoDataError)?;

    Ok(HttpResponse::Ok().json(ReviewEmotionResponse {
        review_emotion: ReviewEmotionData::from(stored),
    }))
}

/// ReviewEmotion input on Put
#[derive(serde::Deserialize, Debug)]
pub struct PutReviewEmotion {
    review_emotion: PutReviewEmotionData,
}

/// ReviewEmotion input data on Put
#[derive(serde::Deserialize, Debug)]
pub struct PutReviewEmotionData {
    emotion: Option<String>,
    position: Option<i32>,
    notes: Option<String>,
}

impl TryFrom<PutReviewEmotionData> for UpdateReviewEmotion {
    type Error = String;
    fn try_from(value: PutReviewEmotionData) -> Result<Self, Self::Error> {
        let emotion = match &value.emotion {
            Some(e) => Some(Emotion::from_str(e).map_err(|e| e.to_string())?),
            None => None,
        };
        let notes = match &value.notes {
            Some(t) => Some(LongFormText::parse(t.to_string())?),
            None => None,
        };
        let position = match &value.position {
            Some(p) => Some(EmotionPosition::parse(*p)?),
            None => None,
        };
        Ok(Self {
            emotion,
            position,
            notes,
        })
    }
}

// TODO Add support for patch
/// API for updating a review_emotion
#[tracing::instrument(
    name = "Putting a review_emotion",
    skip(pool, json),
    fields(
        slug = %slug,
        position = %position
    )
)]
pub async fn put_review_emotion(
    user_id: web::ReqData<UserId>,
    slug: web::Path<String>,
    position: web::Path<i32>,
    json: web::Json<PutReviewEmotion>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ReviewEmotionError> {
    let user_id = user_id.into_inner();
    let slug = ReviewSlug::parse(slug.to_string()).map_err(ReviewEmotionError::ValidationError)?;
    let position =
        EmotionPosition::parse(*position).map_err(ReviewEmotionError::ValidationError)?;

    block_non_creator(&slug, user_id, &pool.get_ref()).await?;
    let updated_review_emotion = json
        .0
        .review_emotion
        .try_into()
        .map_err(ReviewEmotionError::ValidationError)?;
    let stored = update_review_emotion(&slug, &updated_review_emotion, position, &pool)
        .await
        .map_err(ReviewEmotionError::NoDataError)?;
    Ok(HttpResponse::Ok().json(ReviewEmotionResponse {
        review_emotion: ReviewEmotionData::from(stored),
    }))
}

/// API for deleting a review_emotion
#[tracing::instrument(
    name = "Deleting a review_emotion",
    skip(pool),
    fields(
        slug = %slug,
    )
)]
pub async fn delete_review_emotion_by_slug(
    slug: web::Path<String>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ReviewEmotionError> {
    let slug =
        ReviewEmotionSlug::parse(slug.to_string()).map_err(ReviewEmotionError::ValidationError)?;
    delete_review_emotion(&slug, &pool)
        .await
        .context("delete query failed")?;
    Ok(HttpResponse::Ok().finish())
}

/// Emotion Error expresses problems that can happen during the evaluation of the emotions api.
#[derive(thiserror::Error)]
pub enum EmotionError {
    #[error(transparent)]
    // TODO make a more general db error and separate from no data
    /// Nothing found from the database
    NoDataError(#[from] sqlx::Error),

    /// Any other error that could happen
    #[error(transparent)]
    UnexpectedError(#[from] anyhow::Error),
}

impl std::fmt::Debug for EmotionError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        error_chain_fmt(self, f)
    }
}

impl ResponseError for EmotionError {
    fn status_code(&self) -> StatusCode {
        match self {
            EmotionError::NoDataError(_) => StatusCode::NOT_FOUND,
            EmotionError::UnexpectedError(_) => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}

/// API for getting all of the emotions stored in the db
#[tracing::instrument(name = "Getting all emotions", skip(pool), fields())]
pub async fn get_all_emotions(pool: web::Data<PgPool>) -> Result<HttpResponse, EmotionError> {
    let stored = retreive_all_emotions(pool.get_ref())
        .await
        .map_err(EmotionError::NoDataError)?;

    Ok(HttpResponse::Ok().json(stored))
}
