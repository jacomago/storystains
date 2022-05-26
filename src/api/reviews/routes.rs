use actix_web::{http::StatusCode, web, HttpResponse, ResponseError};

use anyhow::Context;
use sqlx::PgPool;

use crate::api::error_chain_fmt;

use super::{
    db::{create_review, delete_review, read_review, update_review},
    model::{NewReview, ReviewResponse, ReviewSlug, ReviewText, ReviewTitle, UpdateReview},
};

#[derive(thiserror::Error)]
pub enum ReviewError {
    #[error("{0}")]
    ValidationError(String),
    #[error(transparent)]
    NoDataError(#[from] sqlx::Error),
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
            ReviewError::NoDataError(_) => StatusCode::NOT_FOUND,
            ReviewError::UnexpectedError(_) => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}

#[derive(serde::Deserialize)]
pub struct PostReview {
    review: PostReviewData,
}

#[derive(serde::Deserialize)]
pub struct PostReviewData {
    title: String,
    review: String,
}

impl TryFrom<PostReviewData> for NewReview {
    type Error = String;
    fn try_from(value: PostReviewData) -> Result<Self, Self::Error> {
        let title = ReviewTitle::parse(value.title)?;
        let text = ReviewText::parse(value.review)?;
        let slug = ReviewSlug::parse(title.slugify())?;
        Ok(Self { title, text, slug })
    }
}

#[tracing::instrument(
    name = "Adding a new review",
    skip(json, pool),
    fields(
        reviews_title = %json.review.title,
        reviews_review = %json.review.review
    )
)]
pub async fn post_review(
    json: web::Json<PostReview>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ReviewError> {
    let new_review = json
        .0
        .review
        .try_into()
        .map_err(ReviewError::ValidationError)?;
    let stored = create_review(&new_review, pool.get_ref())
        .await
        .context("Failed to store new review.")?;
    Ok(HttpResponse::Ok().json(ReviewResponse::from(stored)))
}

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

    Ok(HttpResponse::Ok().json(ReviewResponse::from(stored)))
}

#[derive(serde::Deserialize, Debug)]
pub struct PutReview {
    review: PutReviewData,
}

#[derive(serde::Deserialize, Debug)]
pub struct PutReviewData {
    title: Option<String>,
    review: Option<String>,
}

impl TryFrom<PutReviewData> for UpdateReview {
    type Error = String;
    fn try_from(value: PutReviewData) -> Result<Self, Self::Error> {
        let title = match &value.title {
            Some(t) => Some(ReviewTitle::parse(t.to_string())?),
            None => None,
        };
        let text = match &value.review {
            Some(t) => Some(ReviewText::parse(t.to_string())?),
            None => None,
        };
        let slug = match &title {
            Some(t) => Some(ReviewSlug::parse(t.slugify())?),
            None => None,
        };
        Ok(Self { title, text, slug })
    }
}

#[tracing::instrument(
    name = "Putting a review",
    skip(pool, json),
    fields(
        slug = %slug,
    )
)]
pub async fn put_review(
    slug: web::Path<String>,
    json: web::Json<PutReview>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ReviewError> {
    let slug = ReviewSlug::parse(slug.to_string()).map_err(ReviewError::ValidationError)?;
    let updated_review = json
        .0
        .review
        .try_into()
        .map_err(ReviewError::ValidationError)?;
    let stored = update_review(&slug, &updated_review, &pool)
        .await
        .map_err(ReviewError::NoDataError)?;
    Ok(HttpResponse::Ok().json(ReviewResponse::from(stored)))
}

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
