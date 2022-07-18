use actix_web::{web, HttpResponse};
use anyhow::Context;
use sqlx::PgPool;

use crate::api::shared::ApiError;

use super::{db::retreive_all_emotions, EmotionData};

/// API for getting a list of all emotions
#[tracing::instrument(name = "Getting emotions", skip(), fields())]
pub async fn get_emotions(pool: web::Data<PgPool>) -> Result<HttpResponse, ApiError> {
    let emotions_data = retreive_all_emotions(pool.get_ref())
        .await
        .context("Error gettting emotion details from db")?
        .into_iter()
        .map(EmotionData::from)
        .collect::<Vec<EmotionData>>();
    Ok(HttpResponse::Ok().json(serde_json::json!({ "emotions": emotions_data })))
}
