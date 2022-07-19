use actix_web::ResponseError;
use reqwest::StatusCode;

// TODO Aim to not do crate level imports
use crate::{api::users::NewUsername, auth::AuthUser};

use super::error_chain_fmt;

/// Block Error is to announce error when modifying another users data
#[derive(thiserror::Error)]
pub enum BlockError {
    #[error("{0}")]
    /// Not Allowed Error i.e. user editing another users review
    NotAllowed(String),
    #[error(transparent)]
    // TODO make a more general db error and separate from no data
    /// Nothing found from the database
    NotData(#[from] sqlx::Error),
}

impl std::fmt::Debug for BlockError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        error_chain_fmt(self, f)
    }
}

impl ResponseError for BlockError {
    fn status_code(&self) -> StatusCode {
        match self {
            BlockError::NotAllowed(_) => StatusCode::FORBIDDEN,
            BlockError::NotData(_) => StatusCode::NOT_FOUND,
        }
    }
}
// TODO convert to middleware
pub async fn block_non_creator(
    username: &NewUsername,
    auth_user: &AuthUser,
) -> Result<(), BlockError> {
    if username.as_ref() != auth_user.username && !auth_user.is_admin {
        return Err(BlockError::NotAllowed(
            "Must be the creator of the data.".to_string(),
        ));
    }
    Ok(())
}
