use actix_web::{web, HttpResponse, ResponseError};
use anyhow::Context;
use reqwest::StatusCode;
use sqlx::PgPool;

use crate::api::error_chain_fmt;

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

#[tracing::instrument(name = "Check DB status", skip(pool))]
pub async fn db_check(pool: web::Data<PgPool>) -> Result<HttpResponse, CheckError> {
    sqlx::query!(
        r#"
        SELECT success
        FROM _sqlx_migrations
    "#
    )
    .fetch_one(pool.get_ref())
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })
    .context("Failed to connect to db.")?;
    Ok(HttpResponse::Ok().finish())
}
