mod shared;
pub use shared::consistancy::*;
pub use shared::long_form_text::*;

mod reviews;
pub use reviews::routes::*;

mod emotions;
pub use emotions::routes::*;

mod users;
pub use users::db::*;
pub use users::model::UserId;
pub use users::routes::*;

mod health_check;
pub use health_check::db_check;
pub use health_check::health_check;

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

// TODO move to config
const DEFAULT_LIMIT: u64 = 20;

/// Basic query limits
#[derive(Debug, serde::Deserialize)]
pub struct QueryLimits {
    limit: Option<u64>,
    offset: Option<u64>,
}

/// Query limits without being optional for database level
#[derive(Debug)]
pub struct Limits {
    limit: i64,
    offset: i64,
}

impl From<QueryLimits> for Limits {
    fn from(query: QueryLimits) -> Self {
        let limit = query.limit.unwrap_or(DEFAULT_LIMIT);
        let offset = query.offset.unwrap_or(0);
        Self {
            limit: limit as i64,
            offset: offset as i64,
        }
    }
}
