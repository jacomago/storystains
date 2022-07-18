use actix_web::{web, HttpResponse};

use sqlx::PgPool;

use super::shared::ApiError;

/// Checks if the api is alive.
/// Returns OK if so.
pub async fn health_check() -> HttpResponse {
    HttpResponse::Ok().finish()
}

/// Checks if can connect to the database
/// Returns OK if it can.
#[tracing::instrument(name = "Check DB status", skip(pool))]
pub async fn db_check(pool: web::Data<PgPool>) -> Result<HttpResponse, ApiError> {
    sqlx::query!("SELECT TRUE;")
        .fetch_one(pool.get_ref())
        .await?;

    Ok(HttpResponse::Ok().finish())
}
