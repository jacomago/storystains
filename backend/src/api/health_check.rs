use actix_web::{web, HttpResponse};

use anyhow::Context;
use sqlx::PgPool;

use super::{emotions::emotions_check, shared::ApiError};

/// Checks if the api is alive.
/// Returns OK if so.
pub async fn health_check() -> HttpResponse {
    HttpResponse::Ok().finish()
}

/// Checks if can connect to the database
/// Returns OK if it can.
#[tracing::instrument(name = "Check DB status", skip(pool))]
pub async fn db_check(pool: web::Data<PgPool>) -> Result<HttpResponse, ApiError> {
    emotions_check(pool)
        .await
        .context("Check on emotions failed.")?;

    Ok(HttpResponse::Ok().finish())
}
