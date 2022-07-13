use actix_web::{web, HttpResponse};
use anyhow::Context;
use sqlx::PgPool;

use crate::api::shared::ApiError;

use super::{
    db::{create_story, read_stories},
    model::{StoriesResponse, StoryQuery, StoryResponse},
    StoryResponseData,
};

/// Story input on Post
#[derive(serde::Deserialize)]
pub struct PostStory {
    story: StoryResponseData,
}

/// API for adding a new story
#[tracing::instrument(
    name = "Adding a new story",
    skip(json, pool),
    fields(
        storys_title   = %json.story.title,
        storys_medium  = %json.story.medium,
        storys_creator = %json.story.creator
    )
)]
pub async fn post_story(
    json: web::Json<PostStory>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ApiError> {
    let new_story = json.0.story.try_into().map_err(ApiError::Validation)?;
    let stored = create_story(&new_story, pool.get_ref())
        .await
        .context("Failed to store new story.")?;
    Ok(HttpResponse::Ok().json(StoryResponse {
        story: StoryResponseData::from(stored),
    }))
}

/// API for getting many story via an input query of limit
#[tracing::instrument(name = "Getting stories", skip(pool, query), fields())]
pub async fn get_stories(
    query: web::Query<StoryQuery>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ApiError> {
    let stored = read_stories(query.0, pool.get_ref())
        .await
        .map_err(ApiError::NotData)?;
    Ok(HttpResponse::Ok().json(StoriesResponse::from(stored)))
}
