use actix_web::web;
use anyhow::Context;
use sqlx::PgPool;

use super::db::store_emotions;
use super::EmotionError;

use crate::api::emotions::db::retreive_all_emotions;
use crate::api::emotions::model::{check_emotions, emotions};

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

/// Update all emotions if not already inserted
#[tracing::instrument(name = "Insert emotions if not exist", skip(pool), fields())]
pub async fn insert_emotions(pool: &PgPool) -> Result<(), EmotionError> {
    let stored = retreive_all_emotions(&pool)
        .await
        .map_err(EmotionError::NoDataError)?;
    match stored.len() {
        0 => {
            store_emotions(emotions(), &pool)
                .await
                .context("Problems storing the emotions enum")?;
        }
        _ => {}
    }
    Ok(())
}
