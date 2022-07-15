use crate::api::{shared::QueryLimits, stories::StoryQueryOptions};

/// Review Query Options
#[derive(serde::Deserialize, serde::Serialize, Debug)]
pub struct ReviewQueryOptions {
    pub username: Option<String>,
    pub story_query: StoryQueryOptions,
}

/// Review Query
#[derive(serde::Deserialize, serde::Serialize, Debug)]
pub struct ReviewQuery {
    /// Username of user
    pub username: Option<String>,
    #[serde(flatten)]
    pub story_query: StoryQueryOptions,
    /// Standard pagination limits
    pub limit: Option<u64>,
    pub offset: Option<u64>,
}

impl ReviewQuery {
    // due to bug https://github.com/serde-rs/serde/issues/1183
    // currently cannot use serde(flatten) with non strings
    pub fn query_limits(&self) -> QueryLimits {
        QueryLimits {
            limit: self.limit,
            offset: self.offset,
        }
    }

    pub fn query_options(&self) -> ReviewQueryOptions {
        ReviewQueryOptions {
            username: self.username.clone(),
            story_query: self.story_query.clone(),
        }
    }
}
