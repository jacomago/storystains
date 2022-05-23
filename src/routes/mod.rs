mod health_check;
mod reviews;

use actix_web::HttpResponse;
pub use health_check::*;

use actix_web::http::header::LOCATION;
pub use reviews::*;

pub fn see_other(location: &str) -> HttpResponse {
    HttpResponse::SeeOther()
        .insert_header((LOCATION, location))
        .finish()
}
