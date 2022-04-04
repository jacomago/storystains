use actix_web::{HttpResponse,  web};


#[derive(serde::Deserialize)]
pub struct FormData {
    title: String,
    review: String
}

pub async fn review(_form: web::Form<FormData>) -> HttpResponse {
    HttpResponse::Ok().finish()
}
