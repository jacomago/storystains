use actix_web::{HttpResponse, ResponseError};
use reqwest::StatusCode;

use crate::api::{emotions::model::emotions, shared::error_chain_fmt, EmotionData};

/// API for getting a list of all emotions
#[tracing::instrument(name = "Getting emotions", skip(), fields())]
pub async fn get_emotions() -> Result<HttpResponse, actix_web::Error> {
    let emotions_data = emotions()
        .into_iter()
        .map(EmotionData::from)
        .collect::<Vec<EmotionData>>();
    Ok(HttpResponse::Ok().json(serde_json::json!({ "emotions": emotions_data })))
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
