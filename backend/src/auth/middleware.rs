use actix_web::{
    body::MessageBody,
    dev::{ServiceRequest, ServiceResponse},
    error::InternalError,
    FromRequest, HttpMessage, HttpResponse,
};
use actix_web_lab::middleware::Next;

use crate::session_state::TypedSession;

use super::AuthError;

/// Return an opaque 500 while preserving the error root's cause for logging.
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

/// Rejects anonymous users from auth backed api points
pub async fn reject_anonymous_users(
    mut req: ServiceRequest,
    next: Next<impl MessageBody>,
) -> Result<ServiceResponse<impl MessageBody>, actix_web::Error> {
    let session = {
        let (http_request, payload) = req.parts_mut();
        TypedSession::from_request(http_request, payload).await
    }?;
    match session.get_user().map_err(e500)? {
        Some(user) => {
            req.extensions_mut().insert(user);
            next.call(req).await
        }
        None => Err(actix_web::Error::from(AuthError::InvalidCredentials(
            anyhow::anyhow!("User not logged in."),
        ))),
    }
}
