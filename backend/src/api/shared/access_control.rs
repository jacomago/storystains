use actix_web::ResponseError;
use reqwest::StatusCode;

// TODO Aim to not do crate level imports
use crate::{api::users::NewUsername, auth::AuthUser};

use super::error_chain_fmt;

pub enum ACLOption {
    OwnerOnly,
    OwnerAndAdmin,
}

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

fn owner_block(data_owner: &NewUsername, auth_user: &AuthUser) -> Result<(), BlockError> {
    if data_owner.as_ref() != auth_user.username {
        return Err(BlockError::NotAllowed(
            "Must be the creator of the data.".to_string(),
        ));
    }
    Ok(())
}

// TODO convert to middleware or guard
pub async fn access_control_block(
    data_owner: &NewUsername,
    auth_user: &AuthUser,
    acl_option: ACLOption,
) -> Result<(), BlockError> {
    match acl_option {
        ACLOption::OwnerOnly => owner_block(data_owner, auth_user),
        ACLOption::OwnerAndAdmin => {
            if auth_user.is_admin {
                return Ok(());
            }
            owner_block(data_owner, auth_user)
        }
    }
}
