use actix_web::HttpResponse;

use super::{emotions, EmotionData};

/// API for getting a list of all emotions
#[tracing::instrument(name = "Getting emotions", skip(), fields())]
pub async fn get_emotions() -> Result<HttpResponse, actix_web::Error> {
    let emotions_data = emotions()
        .into_iter()
        .map(EmotionData::from)
        .collect::<Vec<EmotionData>>();
    Ok(HttpResponse::Ok().json(serde_json::json!({ "emotions": emotions_data })))
}
