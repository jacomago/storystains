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
    pub limit: Option<i64>,
    pub offset: i64,
}

impl From<QueryLimits> for Limits {
    fn from(query: QueryLimits) -> Self {
        let limit = query.limit.unwrap_or(DEFAULT_LIMIT);
        let offset = query.offset.unwrap_or(0);
        Self {
            limit: Some(limit as i64),
            offset: offset as i64,
        }
    }
}
