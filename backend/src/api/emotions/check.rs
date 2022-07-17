use actix_web::web;
use sqlx::PgPool;

use crate::api::shared::ApiError;

use super::{db::retreive_all_emotions, model::check_emotions};

/// API for checking all emotions in db are correct to the enum
#[tracing::instrument(name = "Check emotions against Enum", skip(pool), fields())]
pub async fn emotions_check(pool: web::Data<PgPool>) -> Result<(), ApiError> {
    let stored = retreive_all_emotions(pool.get_ref())
        .await
        .map_err(ApiError::NotData)?;
    match check_emotions(stored) {
        Ok(_) => Ok(()),
        Err(e) => Err(ApiError::Unexpected(anyhow::anyhow!(
            "Error occured: {}",
            e
        ))),
    }
}
