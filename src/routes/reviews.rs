use actix_web::{http::StatusCode, web, HttpResponse, ResponseError};

use anyhow::Context;
use sqlx::PgPool;

use crate::{
    db::{create_review, delete_review, read_review, update_review},
    domain::{NewReview, ReviewSlug, ReviewText, ReviewTitle, UpdateReview},
};

use super::{error_chain_fmt, see_other};

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
pub struct FormData {
    title: String,
    review: String,
}

impl TryFrom<FormData> for NewReview {
    type Error = String;
    fn try_from(value: FormData) -> Result<Self, Self::Error> {
        let title = ReviewTitle::parse(value.title)?;
        let text = ReviewText::parse(value.review)?;
        let slug = ReviewSlug::parse(title.slugify())?;
        Ok(Self { title, text, slug })
    }
}

#[tracing::instrument(
    name = "Adding a new review",
    skip(form, pool),
    fields(
        reviews_title = %form.title,
        reviews_review = %form.review
    )
)]
pub async fn post_review(
    form: web::Form<FormData>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ReviewError> {
    let new_review = form.0.try_into().map_err(ReviewError::ValidationError)?;
    create_review(&new_review, pool.get_ref())
        .await
        .context("Failed to store new review.")?;
    Ok(see_other(format!("/reviews/{}", new_review.slug).as_str()))
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
    let stored_review = read_review(&slug, pool.get_ref())
        .await
        .map_err(ReviewError::NoDataError)?;

    Ok(HttpResponse::Ok().json(stored_review))
}

#[derive(serde::Deserialize, Debug)]
pub struct UpdateFormData {
    title: Option<String>,
    review: Option<String>,
}

impl TryFrom<UpdateFormData> for UpdateReview {
    type Error = String;
    fn try_from(value: UpdateFormData) -> Result<Self, Self::Error> {
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
    skip(pool, form),
    fields(
        slug = %slug,
    )
)]
pub async fn put_review(
    slug: web::Path<String>,
    form: web::Form<UpdateFormData>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ReviewError> {
    let slug = ReviewSlug::parse(slug.to_string()).map_err(ReviewError::ValidationError)?;
    let updated_review = form.0.try_into().map_err(ReviewError::ValidationError)?;
    let slug = update_review(&slug, &updated_review, &pool)
        .await
        .map_err(ReviewError::NoDataError)?;
    Ok(see_other(format!("/reviews/{}", slug).as_str()))
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
