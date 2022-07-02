use actix_web::{http::StatusCode, web, HttpResponse, ResponseError};
use serde::Deserialize;

use crate::{
    api::{
        review_emotion::delete_review_emotions_by_review,
        shared::put_block::{block_non_creator, BlockError},
        shared::{error_chain_fmt, QueryLimits},
        stories::{NewStory, StoryResponseData},
        users::NewUsername,
        LongFormText, UserId,
    },
    auth::AuthUser,
};
use anyhow::Context;
use sqlx::PgPool;

use super::{
    db::{
        create_review, delete_review, read_review, read_reviews, review_id_by_username_and_slug,
        update_review,
    },
    model::{
        NewReview, ReviewQueryOptions, ReviewResponse, ReviewResponseData, ReviewSlug,
        ReviewsResponse, UpdateReview,
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
    story: StoryResponseData,
    body: String,
}

impl TryFrom<(PostReviewData, UserId)> for NewReview {
    type Error = String;
    fn try_from((value, user_id): (PostReviewData, UserId)) -> Result<Self, Self::Error> {
        let story: NewStory = value.story.try_into()?;
        let body = LongFormText::parse(value.body)?;
        let slug = ReviewSlug::parse(story.slugify())?;
        Ok(Self {
            story,
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
        reviews_title = %json.review.story.title,
        reviews_review = %json.review.body
    )
)]
pub async fn post_review(
    auth_user: web::ReqData<AuthUser>,
    json: web::Json<PostReview>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ReviewError> {
    let user_id = auth_user.into_inner().user_id;
    let new_review = (json.0.review, user_id)
        .try_into()
        .map_err(ReviewError::ValidationError)?;
    let stored = create_review(&new_review, pool.get_ref())
        .await
        .context("Failed to store new review.")?;
    Ok(HttpResponse::Ok().json(ReviewResponse {
        review: ReviewResponseData::from(stored),
    }))
}

/// Input parameters for accessing a review emotion url
#[derive(Deserialize)]
pub struct ReviewPath {
    /// username from path
    pub username: String,
    /// slug of review in path
    pub slug: String,
}

/// API for getting a review, takes slug as id
#[tracing::instrument(
    name = "Getting a review",
    skip(pool, path),
    fields(
        slug = %path.slug,
    )
)]
pub async fn get_review(
    path: web::Path<ReviewPath>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ReviewError> {
    let slug = ReviewSlug::parse(path.slug.to_string()).map_err(ReviewError::ValidationError)?;
    let username =
        NewUsername::parse(path.username.to_string()).map_err(ReviewError::ValidationError)?;
    let stored = read_review(&username, &slug, pool.get_ref())
        .await
        .map_err(ReviewError::NoDataError)?;
    Ok(HttpResponse::Ok().json(ReviewResponse {
        review: ReviewResponseData::from(stored),
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
    story: Option<StoryResponseData>,
    body: Option<String>,
}

impl TryFrom<PutReviewData> for UpdateReview {
    type Error = String;
    fn try_from(value: PutReviewData) -> Result<Self, Self::Error> {
        let story = value.story.map(NewStory::try_from).transpose()?;
        let body = value.body.map(LongFormText::parse).transpose()?;
        Ok(Self { story, body })
    }
}

// TODO Add support for patch
/// API for updating a review
#[tracing::instrument(
    name = "Putting a review",
    skip(pool, json, path),
    fields(
        slug = %path.slug,
        reviews_body = %format!("{:?}",json.review.body)
    )
)]
pub async fn put_review(
    path: web::Path<ReviewPath>,
    auth_user: web::ReqData<AuthUser>,
    json: web::Json<PutReview>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ReviewError> {
    let slug = ReviewSlug::parse(path.slug.to_string()).map_err(ReviewError::ValidationError)?;
    let username =
        NewUsername::parse(path.username.to_string()).map_err(ReviewError::ValidationError)?;

    block_non_creator(&username, &auth_user.into_inner()).await?;
    let updated_review = json
        .0
        .review
        .try_into()
        .map_err(ReviewError::ValidationError)?;
    let stored = update_review(&username, &slug, &updated_review, &pool)
        .await
        .map_err(ReviewError::NoDataError)?;
    Ok(HttpResponse::Ok().json(ReviewResponse {
        review: ReviewResponseData::from(stored),
    }))
}

/// API for deleting a review
#[tracing::instrument(
    name = "Deleting a review",
    skip(pool, path),
    fields(
        slug = %path.slug,
    )
)]
pub async fn delete_review_by_slug(
    path: web::Path<ReviewPath>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ReviewError> {
    let slug = ReviewSlug::parse(path.slug.to_string()).map_err(ReviewError::ValidationError)?;
    let username =
        NewUsername::parse(path.username.to_string()).map_err(ReviewError::ValidationError)?;

    let review_id = review_id_by_username_and_slug(&username, &slug, pool.get_ref())
        .await
        .map_err(ReviewError::NoDataError)?;

    let mut transaction = pool
        .begin()
        .await
        .context("Failed to acquire a Postgres connection from the pool")?;
    delete_review_emotions_by_review(&review_id, &mut transaction)
        .await
        .context("delete review emotions query failed")?;
    delete_review(&review_id, &mut transaction)
        .await
        .context("delete review query failed")?;
    transaction
        .commit()
        .await
        .context("Failed to commit SQL transaction to delete user and data.")?;
    Ok(HttpResponse::Ok().finish())
}

/// API for getting many review via an input query of offset and limit
#[tracing::instrument(name = "Getting reviews", skip(pool, query), fields())]
pub async fn get_reviews(
    query: web::Query<QueryLimits>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ReviewError> {
    let limits = query.0.into();
    let reviews = read_reviews(
        &ReviewQueryOptions { user_id: None },
        &limits,
        pool.get_ref(),
    )
    .await
    .map_err(ReviewError::NoDataError)?;
    Ok(HttpResponse::Ok().json(ReviewsResponse::from(reviews)))
}
