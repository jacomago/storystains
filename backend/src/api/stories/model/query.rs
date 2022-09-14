use crate::api::shared::QueryLimits;

/// Story query options
#[derive(serde::Deserialize, serde::Serialize, Debug, PartialEq, Eq, Clone)]
pub struct StoryQueryOptions {
    /// Story title matching string
    pub title: Option<String>,
    /// Story title matching medium - must match a medium
    pub medium: Option<String>,
    /// Story creator matching string
    pub creator: Option<String>,
}

/// Story query
#[derive(serde::Deserialize, serde::Serialize, Debug, PartialEq, Eq)]
pub struct StoryQuery {
    #[serde(flatten)]
    pub options: StoryQueryOptions,
    /// Standard pagination limits
    pub limit: Option<u64>,
    pub offset: Option<u64>,
}

impl StoryQuery {
    // due to bug https://github.com/serde-rs/serde/issues/1183
    // currently cannot use serde(flatten) with non strings
    pub fn query_limits(&self) -> QueryLimits {
        QueryLimits {
            limit: self.limit,
            offset: self.offset,
        }
    }
}

#[cfg(test)]
mod tests {

    use crate::api::stories::StoryQueryOptions;

    use super::StoryQuery;
    use actix_web::web::Query;

    #[test]
    fn test_limit_string() {
        let text = "limit=10".to_string();
        assert_eq!(
            Query::<StoryQuery>::from_query(&text).unwrap().0,
            StoryQuery {
                options: StoryQueryOptions {
                    title: None,
                    medium: None,
                    creator: None,
                },
                limit: Some(10),
                offset: None
            }
        );
    }
    #[test]
    fn test_title_limit_string() {
        let text = "limit=10&title=Frank".to_string();
        assert_eq!(
            Query::<StoryQuery>::from_query(&text).unwrap().0,
            StoryQuery {
                options: StoryQueryOptions {
                    title: Some("Frank".to_string()),
                    medium: None,
                    creator: None,
                },
                limit: Some(10),
                offset: None
            }
        );
    }
}
