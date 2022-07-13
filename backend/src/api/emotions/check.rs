use actix_web::web;
use sqlx::PgPool;

use crate::api::emotions::db::retreive_all_emotions;
use crate::api::emotions::model::check_emotions;
use crate::api::shared::ApiError;

/// API for checking all emotions in db are correct to the enum
#[tracing::instrument(name = "Check emotions against Enum", skip(pool), fields())]
pub async fn emotions_check(pool: web::Data<PgPool>) -> Result<(), ApiError> {
    let stored = retreive_all_emotions(pool.get_ref())
        .await
        .map_err(ApiError::NoDataError)?;
    match check_emotions(stored) {
        Ok(_) => Ok(()),
        Err(e) => Err(ApiError::UnexpectedError(anyhow::anyhow!(
            "Error occured: {}",
            e
        ))),
    }
}
