use actix_web::{dev::ServiceRequest, error::InternalError, web, HttpMessage, HttpResponse};
use actix_web_httpauth::extractors::bearer::BearerAuth;

use crate::{
    api::UserId,
    startup::{ExpTokenSeconds, HmacSecret},
};

use super::jwt;

// Return an opaque 500 while preserving the error root's cause for logging.
pub fn e500<T>(e: T) -> actix_web::Error
where
    T: std::fmt::Debug + std::fmt::Display + 'static,
{
    actix_web::error::ErrorInternalServerError(e)
}

pub async fn bearer_auth(
    req: ServiceRequest,
    credentials: BearerAuth,
) -> Result<ServiceRequest, actix_web::Error> {
    let key = {
        match req.app_data::<web::Data<HmacSecret>>() {
            Some(secret) => secret,
            None => {
                let response = HttpResponse::InternalServerError().finish();
                let e = anyhow::anyhow!("Error retreiving secret.");
                return Err(InternalError::from_response(e, response).into());
            }
        }
    };
    let exp_seconds = {
        match req.app_data::<web::Data<ExpTokenSeconds>>() {
            Some(sec) => sec,
            None => {
                let response = HttpResponse::InternalServerError().finish();
                let e = anyhow::anyhow!("Error retreiving secret.");
                return Err(InternalError::from_response(e, response).into());
            }
        }
    };
    let leeway = exp_seconds.0 as f64 * 0.1;
    let token = credentials.token();
    let claim = jwt::decode_token(token, key, leeway as u64);
    match claim {
        Some(c) => {
            req.extensions_mut().insert(UserId::new(c.id));
            Ok(req)
        }
        None => {
            let response = HttpResponse::Unauthorized().finish();
            let e = anyhow::anyhow!("The user has not logged in");
            Err(InternalError::from_response(e, response).into())
        }
    }
}
