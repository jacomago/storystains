use actix_web::{web, HttpResponse};
use sqlx::PgPool;

use crate::api::shared::ApiError;

use super::{db::retreive_all_mediums, MediumData};

/// API for getting a list of all mediums
#[tracing::instrument(name = "Getting mediums", skip(), fields())]
pub async fn get_mediums(pool: web::Data<PgPool>) -> Result<HttpResponse, actix_web::Error> {
    let mediums_data = retreive_all_mediums(pool.get_ref())
        .await
        .map_err(ApiError::NotData)?
        .into_iter()
        .map(MediumData::from)
        .collect::<Vec<MediumData>>();
    Ok(HttpResponse::Ok().json(serde_json::json!({ "mediums": mediums_data })))
}
