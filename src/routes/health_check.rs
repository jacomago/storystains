use actix_web::{HttpResponse, Responder};


async fn health_check() -> impl Responder {
    HttpResponse::Ok()
}
