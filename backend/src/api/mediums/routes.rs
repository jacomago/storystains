use actix_web::{web, HttpResponse, ResponseError};
use reqwest::StatusCode;
use sqlx::PgPool;

use crate::api::shared::error_chain_fmt;

use super::{db::retreive_all_mediums, MediumData};

/// API for getting a list of all mediums
#[tracing::instrument(name = "Getting mediums", skip(), fields())]
pub async fn get_mediums(pool: web::Data<PgPool>) -> Result<HttpResponse, actix_web::Error> {
    let mediums_data = retreive_all_mediums(pool.get_ref())
        .await
        .map_err(MediumError::NoDataError)?
        .into_iter()
        .map(MediumData::from)
        .collect::<Vec<MediumData>>();
    Ok(HttpResponse::Ok().json(serde_json::json!({ "mediums": mediums_data })))
}

/// Medium Error expresses problems that can happen during the evaluation of the mediums api.
#[derive(thiserror::Error)]
pub enum MediumError {
    #[error(transparent)]
    // TODO make a more general db error and separate from no data
    /// Nothing found from the database
    NoDataError(#[from] sqlx::Error),

    /// Any other error that could happen
    #[error(transparent)]
    UnexpectedError(#[from] anyhow::Error),
}

impl std::fmt::Debug for MediumError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        error_chain_fmt(self, f)
    }
}

impl ResponseError for MediumError {
    fn status_code(&self) -> StatusCode {
        match self {
            MediumError::NoDataError(_) => StatusCode::NOT_FOUND,
            MediumError::UnexpectedError(_) => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}
