use actix_web::{web, HttpResponse, ResponseError};

use anyhow::Context;
use reqwest::StatusCode;
use sqlx::PgPool;

use crate::api::shared::error_chain_fmt;

use super::emotions::emotions_check;

/// Checks if the api is alive.
/// Returns OK if so.
pub async fn health_check() -> HttpResponse {
    HttpResponse::Ok().finish()
}

#[derive(thiserror::Error)]
pub enum CheckError {
    #[error(transparent)]
    UnexpectedError(#[from] anyhow::Error),
}

impl std::fmt::Debug for CheckError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        error_chain_fmt(self, f)
    }
}

impl ResponseError for CheckError {
    fn status_code(&self) -> StatusCode {
        match self {
            CheckError::UnexpectedError(_) => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}

/// Checks if can connect to the database
/// Returns OK if it can.
#[tracing::instrument(name = "Check DB status", skip(pool))]
pub async fn db_check(pool: web::Data<PgPool>) -> Result<HttpResponse, CheckError> {
    emotions_check(pool)
        .await
        .context("Check on emotions failed.")?;

    Ok(HttpResponse::Ok().finish())
}
