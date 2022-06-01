mod reviews;
pub use reviews::routes::*;

mod users;
pub use users::db::*;
pub use users::model::UserId;
pub use users::routes::*;

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

const DEFAULT_LIMIT: i64 = 20;
#[derive(Debug, serde::Deserialize)]
pub struct QueryLimits {
    limit: Option<i64>,
    offset: Option<i64>,
}

#[derive(Debug)]
pub struct Limits {
    limit: i64,
    offset: i64,
}

impl From<QueryLimits> for Limits {
    fn from(query: QueryLimits) -> Self {
        let limit = query.limit.unwrap_or(DEFAULT_LIMIT);
        let offset = query.offset.unwrap_or(0);
        Self { limit, offset }
    }
}
