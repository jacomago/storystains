use actix_cors::Cors;
use actix_web::http;

/// Cross Origin Requests middleware
pub fn cors(frontend_origin: &str) -> Cors {
    Cors::default()
        .allowed_origin(frontend_origin)
        .allowed_header(http::header::CONTENT_TYPE)
        .allowed_methods(vec!["GET", "POST", "PUT", "DELETE"])
        .supports_credentials()
        .max_age(3600)
}
