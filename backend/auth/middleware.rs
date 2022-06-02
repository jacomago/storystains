use actix_web::{dev::ServiceRequest, error::InternalError, web, HttpMessage, HttpResponse};
use actix_web_httpauth::extractors::bearer::BearerAuth;
use anyhow::Context;
use sqlx::PgPool;

use crate::{
    api::{check_user_exists, UserId},
    startup::{ExpTokenSeconds, HmacSecret},
};

use super::{jwt, AuthError};

// Return an opaque 500 while preserving the error root's cause for logging.
pub fn e500<T>(e: T) -> actix_web::Error
where
    T: std::fmt::Debug + std::fmt::Display + 'static,
{
    actix_web::error::ErrorInternalServerError(e)
}

impl From<AuthError> for actix_web::Error {
    fn from(e: AuthError) -> Self {
        let (cause, response) = match e {
            AuthError::InvalidCredentials(e) => (e, HttpResponse::Unauthorized().finish()),
            AuthError::UnexpectedError(e) => (e, HttpResponse::InternalServerError().finish()),
        };
        InternalError::from_response(cause, response).into()
    }
}
pub async fn bearer_auth(
    req: ServiceRequest,
    credentials: BearerAuth,
) -> Result<ServiceRequest, actix_web::Error> {
    let key = req
        .app_data::<web::Data<HmacSecret>>()
        .context("Error retreiving secret.")
        .map_err(AuthError::UnexpectedError)?;
    let exp_seconds = req
        .app_data::<web::Data<ExpTokenSeconds>>()
        .context("Error retreiving exp token seconds.")
        .map_err(AuthError::UnexpectedError)?;

    let leeway = exp_seconds.0 as f64 * 0.1;
    let token = credentials.token();

    let claim = jwt::decode_token(token, key, leeway as u64);

    match claim {
        Some(c) => {
            let pool = req
                .app_data::<web::Data<PgPool>>()
                .context("Error retreiving database pool")
                .map_err(AuthError::UnexpectedError)?;

            let user_id = UserId::new(c.id);
            let user_exists = check_user_exists(&user_id, pool)
                .await
                .context("Error accessing databse")
                .map_err(AuthError::UnexpectedError)?;

            if user_exists {
                req.extensions_mut().insert(user_id);
                Ok(req)
            } else {
                Err(actix_web::Error::from(AuthError::InvalidCredentials(
                    anyhow::anyhow!("User doesn't exist."),
                )))
            }
        }
        None => Err(actix_web::Error::from(AuthError::InvalidCredentials(
            anyhow::anyhow!("User not logged in."),
        ))),
    }
}
