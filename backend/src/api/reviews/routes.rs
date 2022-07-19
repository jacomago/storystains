use actix_web::{web, HttpResponse};
use serde::Deserialize;

use crate::{
    api::{
        review_emotion::delete_review_emotions_by_review,
        shared::{
            access_control::{access_control_block, ACLOption},
            long_form_text::LongFormText,
            ApiError,
        },
        stories::{NewStory, StoryResponseData},
        users::{NewUsername, UserId},
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
        NewReview, ReviewQuery, ReviewResponse, ReviewResponseData, ReviewSlug, ReviewsResponse,
        UpdateReview,
    },
};

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
        reviews_story = %format!("{:?}",json.review.story),
        reviews_review = %json.review.body
    )
)]
pub async fn post_review(
    auth_user: web::ReqData<AuthUser>,
    json: web::Json<PostReview>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ApiError> {
    let user_id = auth_user.into_inner().user_id;
    let new_review = (json.0.review, user_id)
        .try_into()
        .map_err(ApiError::Validation)?;
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
) -> Result<HttpResponse, ApiError> {
    let slug = ReviewSlug::parse(path.slug.to_string()).map_err(ApiError::Validation)?;
    let username = NewUsername::parse(path.username.to_string()).map_err(ApiError::Validation)?;
    let stored = read_review(&username, &slug, pool.get_ref())
        .await
        .map_err(ApiError::NotData)?;
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
        reviews_story = %format!("{:?}",json.review.story),
        reviews_body = %format!("{:?}",json.review.body)
    )
)]
pub async fn put_review(
    path: web::Path<ReviewPath>,
    auth_user: web::ReqData<AuthUser>,
    json: web::Json<PutReview>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ApiError> {
    let slug = ReviewSlug::parse(path.slug.to_string()).map_err(ApiError::Validation)?;
    let username = NewUsername::parse(path.username.to_string()).map_err(ApiError::Validation)?;

    access_control_block(&username, &auth_user.into_inner(), ACLOption::OwnerOnly).await?;
    let updated_review = json.0.review.try_into().map_err(ApiError::Validation)?;
    let stored = update_review(&username, &slug, &updated_review, &pool)
        .await
        .map_err(ApiError::NotData)?;
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
    auth_user: web::ReqData<AuthUser>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ApiError> {
    let slug = ReviewSlug::parse(path.slug.to_string()).map_err(ApiError::Validation)?;
    let username = NewUsername::parse(path.username.to_string()).map_err(ApiError::Validation)?;

    access_control_block(&username, &auth_user.into_inner(), ACLOption::OwnerAndAdmin).await?;
    let review_id = review_id_by_username_and_slug(&username, &slug, pool.get_ref())
        .await
        .map_err(ApiError::NotData)?;

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
    query: web::Query<ReviewQuery>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ApiError> {
    let limits = query.0.query_limits().into();
    let reviews = read_reviews(&query.0.query_options(), &limits, pool.get_ref())
        .await
        .map_err(ApiError::NotData)?;
    Ok(HttpResponse::Ok().json(ReviewsResponse::from(reviews)))
}
