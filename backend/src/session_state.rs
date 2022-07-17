use actix_session::Session;
use actix_session::SessionExt;
use actix_web::dev::Payload;
use actix_web::{FromRequest, HttpRequest};
use std::future::{ready, Ready};

use crate::auth::AuthUser;

impl FromRequest for TypedSession {
    // This is a complicated way of saying
    // "We return the same error returned by the
    // implementation of `FromRequest` for `Session`".
    type Error = <Session as FromRequest>::Error;
    // Rust does not yet support the `async` syntax in traits.
    // From request expects a `Future` as return type to allow for extractors
    // that need to perform asynchronous operations (e.g. a HTTP call)
    // We do not have a `Future`, because we don't perform any I/O,
    // so we wrap `TypedSession` into `Ready` to convert it into a `Future` that
    // resolves to the wrapped value the first time it's polled by the executor.
    type Future = Ready<Result<TypedSession, Self::Error>>;

    fn from_request(req: &HttpRequest, _payload: &mut Payload) -> Self::Future {
        ready(Ok(TypedSession(req.get_session())))
    }
}

/// Wrapper around Session for handling cookies with a typed UserId
pub struct TypedSession(Session);

impl TypedSession {
    const USER_ID_KEY: &'static str = "user_id";

    /// Renew the session
    pub fn renew(&self) {
        self.0.renew();
    }

    /// Insert a user id into the session
    pub fn insert_user(&self, user: AuthUser) -> Result<(), actix_session::SessionInsertError> {
        self.0.insert(Self::USER_ID_KEY, user)
    }

    /// Retrieve the user id from the session
    pub fn get_user(&self) -> Result<Option<AuthUser>, actix_session::SessionGetError> {
        self.0.get(Self::USER_ID_KEY)
    }

    /// Log the user out
    pub fn log_out(self) {
        self.0.purge()
    }
}
