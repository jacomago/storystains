use actix_cors::Cors;
use actix_web::http;

pub fn cors(frontend_origin: &str) -> Cors {
    Cors::default()
        .allowed_origin(frontend_origin)
        .allowed_headers(vec![http::header::AUTHORIZATION, http::header::ACCEPT])
        .allowed_header(http::header::CONTENT_TYPE)
        .allowed_methods(vec!["GET", "POST", "PUT", "DELETE"])
        .max_age(3600)
}
