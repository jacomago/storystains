use actix_web::ResponseError;
use reqwest::StatusCode;

use crate::{
    api::{shared::error_chain_fmt, users::NewUsername},
    auth::AuthUser,
};

/// Block Error is to announce error when modifying another users data
#[derive(thiserror::Error)]
pub enum BlockError {
    #[error("{0}")]
    /// Not Allowed Error i.e. user editing another users review
    NotAllowedError(String),
    #[error(transparent)]
    // TODO make a more general db error and separate from no data
    /// Nothing found from the database
    NoDataError(#[from] sqlx::Error),
}

impl std::fmt::Debug for BlockError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        error_chain_fmt(self, f)
    }
}

impl ResponseError for BlockError {
    fn status_code(&self) -> StatusCode {
        match self {
            BlockError::NotAllowedError(_) => StatusCode::FORBIDDEN,
            BlockError::NoDataError(_) => StatusCode::NOT_FOUND,
        }
    }
}
// TODO convert to middleware and/or don't read from db
pub async fn block_non_creator(
    username: &NewUsername,
    auth_user: &AuthUser,
) -> Result<(), BlockError> {
    if username.as_ref() != auth_user.username {
        return Err(BlockError::NotAllowedError(
            "Must be the creator of the data.".to_string(),
        ));
    }
    Ok(())
}
