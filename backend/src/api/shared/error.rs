use actix_web::ResponseError;
use reqwest::StatusCode;

use super::put_block::BlockError;

/// Api Error expresses problems that can happen during the evaluation of the api.
#[derive(thiserror::Error)]
pub enum ApiError {
    /// Auth failure
    #[error("Authentication failed")]
    Auth(#[source] anyhow::Error),
    #[error("{0}")]
    /// Validation error i.e. empty title
    Validation(String),
    #[error("{0}")]
    /// Not Allowed Error i.e. user editing another users review
    NotAllowed(String),
    #[error(transparent)]
    // TODO make a more general db error and separate from no data
    /// Nothing found from the database
    NotData(#[from] sqlx::Error),

    /// Any other error that could happen
    #[error(transparent)]
    Unexpected(#[from] anyhow::Error),
}

impl std::fmt::Debug for ApiError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        error_chain_fmt(self, f)
    }
}

impl ResponseError for ApiError {
    fn status_code(&self) -> StatusCode {
        match self {
            ApiError::Auth(_) => StatusCode::BAD_REQUEST,
            ApiError::Validation(_) => StatusCode::BAD_REQUEST,
            ApiError::NotAllowed(_) => StatusCode::FORBIDDEN,
            ApiError::NotData(_) => StatusCode::NOT_FOUND,
            ApiError::Unexpected(_) => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}

impl From<BlockError> for ApiError {
    fn from(e: BlockError) -> Self {
        match e {
            BlockError::NotData(d) => ApiError::NotData(d),
            BlockError::NotAllowed(d) => ApiError::NotAllowed(d),
        }
    }
}

/// Formats errors into a nice format.
pub fn error_chain_fmt(
    e: &impl std::error::Error,
    f: &mut std::fmt::Formatter<'_>,
) -> std::fmt::Result {
    writeln!(f, "{}\n", e)?;
    let mut current = e.source();
    while let Some(cause) = current {
        writeln!(f, "Caused by:\n\t{}", cause)?;
        current = cause.source();
    }
    Ok(())
}
