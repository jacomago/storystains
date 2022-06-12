use std::str::FromStr;

use actix_web::{web, HttpResponse, ResponseError};
use anyhow::Context;
use reqwest::StatusCode;
use sqlx::PgPool;

use crate::api::{emotions::model::emotions, error_chain_fmt, reviews::ReviewSlug, LongFormText};

use super::{
    db::create_review_emotion,
    model::{Emotion, EmotionPosition, NewReviewEmotion, ReviewEmotionData, ReviewEmotionResponse},
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
    slug: web::Path<String>,
    json: web::Json<PostReviewEmotion>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ReviewEmotionError> {
    let slug = ReviewSlug::parse(slug.to_string()).map_err(ReviewEmotionError::ValidationError)?;

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
