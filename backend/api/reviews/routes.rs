use std::iter::zip;

use actix_web::{http::StatusCode, web, HttpResponse, ResponseError};

use crate::api::{
    error_chain_fmt,
    review_emotion::{read_review_emotions, StoredReviewEmotion, ReviewEmotionData},
    shared::put_block::{block_non_creator, BlockError},
    LongFormText, QueryLimits, UserId,
};
use anyhow::Context;
use futures_lite::{stream, StreamExt};
use sqlx::PgPool;

use super::{
    db::{create_review, delete_review, read_review, read_reviews, update_review},
    model::{
        NewReview, ReviewResponse, ReviewResponseData, ReviewSlug, ReviewTitle, ReviewsResponse,
        StoredReview, UpdateReview,
    },
};

/// Review Error expresses problems that can happen during the evaluation of the reviews api.
#[derive(thiserror::Error)]
pub enum ReviewError {
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

impl std::fmt::Debug for ReviewError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        error_chain_fmt(self, f)
    }
}

impl ResponseError for ReviewError {
    fn status_code(&self) -> StatusCode {
        match self {
            ReviewError::ValidationError(_) => StatusCode::BAD_REQUEST,
            ReviewError::NotAllowedError(_) => StatusCode::FORBIDDEN,
            ReviewError::NoDataError(_) => StatusCode::NOT_FOUND,
            ReviewError::UnexpectedError(_) => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}

impl From<BlockError> for ReviewError {
    fn from(e: BlockError) -> Self {
        match e {
            BlockError::NoDataError(d) => ReviewError::NoDataError(d),
            BlockError::NotAllowedError(d) => ReviewError::NotAllowedError(d),
        }
    }
}
/// Review input on Post
#[derive(serde::Deserialize)]
pub struct PostReview {
    review: PostReviewData,
}

/// Data of review input on Post
#[derive(serde::Deserialize)]
pub struct PostReviewData {
    title: String,
    body: String,
}

impl TryFrom<(PostReviewData, UserId)> for NewReview {
    type Error = String;
    fn try_from((value, user_id): (PostReviewData, UserId)) -> Result<Self, Self::Error> {
        let title = ReviewTitle::parse(value.title)?;
        let body = LongFormText::parse(value.body)?;
        let slug = ReviewSlug::parse(title.slugify())?;
        Ok(Self {
            title,
            body,
            slug,
            user_id,
        })
    }
}

/// API for adding a new review
#[tracing::instrument(
    name = "Adding a new review",
    skip(json, pool),
    fields(
        reviews_title = %json.review.title,
        reviews_review = %json.review.body
    )
)]
pub async fn post_review(
    user_id: web::ReqData<UserId>,
    json: web::Json<PostReview>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ReviewError> {
    let user_id = user_id.into_inner();
    let new_review = (json.0.review, user_id)
        .try_into()
        .map_err(ReviewError::ValidationError)?;
    let stored = create_review(&new_review, pool.get_ref())
        .await
        .context("Failed to store new review.")?;
    Ok(HttpResponse::Ok().json(ReviewResponse {
        review: ReviewResponseData::from((stored, vec![])),
    }))
}

/// API for getting a review, takes slug as id
#[tracing::instrument(
    name = "Getting a review",
    skip(pool),
    fields(
        slug = %slug,
    )
)]
pub async fn get_review(
    slug: web::Path<String>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ReviewError> {
    let slug = ReviewSlug::parse(slug.to_string()).map_err(ReviewError::ValidationError)?;
    let stored = read_review(&slug, pool.get_ref())
        .await
        .map_err(ReviewError::NoDataError)?;
    let review_emotions = read_review_emotions(&stored.id, pool.get_ref())
        .await
        .map_err(ReviewError::NoDataError)?;
    Ok(HttpResponse::Ok().json(ReviewResponse {
        review: ReviewResponseData::from((stored, review_emotions)),
    }))
}

/// Review input on Put
#[derive(serde::Deserialize, Debug)]
pub struct PutReview {
    review: PutReviewData,
}

/// Review input data on Put
#[derive(serde::Deserialize, Debug)]
pub struct PutReviewData {
    title: Option<String>,
    body: Option<String>,
}

impl TryFrom<PutReviewData> for UpdateReview {
    type Error = String;
    fn try_from(value: PutReviewData) -> Result<Self, Self::Error> {
        let title = value.title.map(ReviewTitle::parse).transpose()?;
        let body = value.body.map(LongFormText::parse).transpose()?;
        let slug = title
            .as_ref()
            .map(|t| ReviewSlug::parse(t.slugify()))
            .transpose()?;
        Ok(Self { title, body, slug })
    }
}

// TODO Add support for patch
/// API for updating a review
#[tracing::instrument(
    name = "Putting a review",
    skip(pool, json),
    fields(
        slug = %slug,
    )
)]
pub async fn put_review(
    slug: web::Path<String>,
    user_id: web::ReqData<UserId>,
    json: web::Json<PutReview>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ReviewError> {
    let user_id = user_id.into_inner();
    let slug = ReviewSlug::parse(slug.to_string()).map_err(ReviewError::ValidationError)?;

    block_non_creator(&slug, user_id, pool.get_ref()).await?;
    let updated_review = json
        .0
        .review
        .try_into()
        .map_err(ReviewError::ValidationError)?;
    let stored = update_review(&slug, &updated_review, &pool)
        .await
        .map_err(ReviewError::NoDataError)?;
    let review_emotions = read_review_emotions(&stored.id, pool.get_ref())
        .await
        .map_err(ReviewError::NoDataError)?;
    Ok(HttpResponse::Ok().json(ReviewResponse {
        review: ReviewResponseData::from((stored, review_emotions)),
    }))
}

/// API for deleting a review
#[tracing::instrument(
    name = "Deleting a review",
    skip(pool),
    fields(
        slug = %slug,
    )
)]
pub async fn delete_review_by_slug(
    slug: web::Path<String>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ReviewError> {
    let slug = ReviewSlug::parse(slug.to_string()).map_err(ReviewError::ValidationError)?;
    delete_review(&slug, &pool)
        .await
        .context("delete query failed")?;
    Ok(HttpResponse::Ok().finish())
}

/// API for getting many review via an input query of offset and limit
#[tracing::instrument(name = "Getting reviews", skip(pool, query), fields())]
pub async fn get_reviews(
    query: web::Query<QueryLimits>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ReviewError> {
    let limits = query.0.into();
    let stored = read_reviews(&limits, pool.get_ref())
        .await
        .map_err(ReviewError::NoDataError)?;
    let ids: Vec<&sqlx::types::Uuid> = stored.iter().map(|s| &s.id).collect();
    let stream_stored: Result<Vec<Vec<_>>, sqlx::Error> = stream::iter(ids)
        .then(|r| read_review_emotions(r, pool.get_ref()))
        .try_collect()
        .await;
    let emotions = stream_stored.map_err(ReviewError::NoDataError)?;

    let all: Vec<(StoredReview, Vec<ReviewEmotionData>)> = zip(stored, emotions).collect();
    Ok(HttpResponse::Ok().json(ReviewsResponse::from(all)))
}
