use actix_web::{web, HttpResponse, ResponseError};
use anyhow::Context;
use reqwest::StatusCode;
use sqlx::PgPool;

use crate::api::{error_chain_fmt, shared::short_form_text::ShortFormText};

use super::{
    db::create_story,
    model::{NewStory, StoryResponse},
    StoryResponseData,
};

/// Story Error expresses problems that can happen during the evaluation of the stories api.
#[derive(thiserror::Error)]
pub enum StoryError {
    #[error("{0}")]
    /// Validation error i.e. empty title
    ValidationError(String),
    #[error("{0}")]
    /// Not Allowed Error i.e. user editing another users story
    NotAllowedError(String),
    #[error(transparent)]
    // TODO make a more general db error and separate from no data
    /// Nothing found from the database
    NoDataError(#[from] sqlx::Error),

    /// Any other error that could happen
    #[error(transparent)]
    UnexpectedError(#[from] anyhow::Error),
}

impl std::fmt::Debug for StoryError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        error_chain_fmt(self, f)
    }
}

impl ResponseError for StoryError {
    fn status_code(&self) -> StatusCode {
        match self {
            StoryError::ValidationError(_) => StatusCode::BAD_REQUEST,
            StoryError::NotAllowedError(_) => StatusCode::FORBIDDEN,
            StoryError::NoDataError(_) => StatusCode::NOT_FOUND,
            StoryError::UnexpectedError(_) => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}

/// Story input on Post
#[derive(serde::Deserialize)]
pub struct PostStory {
    story: PostStoryData,
}

/// Data of story input on Post
#[derive(serde::Deserialize)]
pub struct PostStoryData {
    title: String,
    medium: String,
    creator: String,
}

impl TryFrom<PostStoryData> for NewStory {
    type Error = String;
    fn try_from(value: PostStoryData) -> Result<Self, Self::Error> {
        let title = ShortFormText::parse(value.title)?;
        let medium = ShortFormText::parse(value.medium)?;
        let creator = ShortFormText::parse(value.creator)?;
        Ok(Self {
            title,
            medium,
            creator,
        })
    }
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
) -> Result<HttpResponse, StoryError> {
    let new_story = json
        .0
        .story
        .try_into()
        .map_err(StoryError::ValidationError)?;
    let stored = create_story(&new_story, pool.get_ref())
        .await
        .context("Failed to store new story.")?;
    Ok(HttpResponse::Ok().json(StoryResponse {
        story: StoryResponseData::from(stored),
    }))
}
