use actix_web::web;
use sqlx::PgPool;

use super::EmotionError;

use crate::api::emotions::db::retreive_all_emotions;
use crate::api::emotions::model::check_emotions;

/// API for checking all emotions in db are correct to the enum
#[tracing::instrument(name = "Check emotions against Enum", skip(pool), fields())]
pub async fn emotions_check(pool: web::Data<PgPool>) -> Result<(), EmotionError> {
    let stored = retreive_all_emotions(pool.get_ref())
        .await
        .map_err(EmotionError::NoDataError)?;
    match check_emotions(stored) {
        Ok(_) => Ok(()),
        Err(e) => Err(EmotionError::UnexpectedError(anyhow::anyhow!(
            "Error occured: {}",
            e
        ))),
    }
}
