use actix_web::HttpResponse;

use crate::api::emotions::model::emotions;


/// API for getting many review via an input query of offset and limit
#[tracing::instrument(name = "Getting emotions", skip(), fields())]
pub async fn get_emotions() -> Result<HttpResponse, actix_web::Error> {
    Ok(HttpResponse::Ok().json(serde_json::json!({ "emotions": emotions() })))
}
