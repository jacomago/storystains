use actix_web::{HttpResponse, Responder, web};


#[derive(serde::Deserialize)]
struct FormData {
    title: String,
    review: String
}

async fn review(_form: web::Form<FormData>) -> HttpResponse {
    HttpResponse::Ok().finish()
}
