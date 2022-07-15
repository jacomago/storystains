use chrono::{DateTime, Utc};

use crate::story::TestStoryQuery;

#[derive(Debug, serde::Serialize, serde::Deserialize, Clone)]
pub struct TestQuery {
    limit: Option<i64>,
    offset: Option<i64>,
    #[serde(flatten)]
    story_query: TestStoryQuery,
    username: Option<String>,
    timestamp: Option<DateTime<Utc>>,
}

impl TestQuery {
    pub fn new() -> Self {
        TestQuery {
            limit: None,
            offset: None,
            story_query: TestStoryQuery::new(),
            username: None,
            timestamp: None,
        }
    }
    pub fn limit(&mut self, limit: i64) -> &mut TestQuery {
        self.limit = Some(limit);
        self
    }
    pub fn offset(&mut self, offset: i64) -> &mut TestQuery {
        self.offset = Some(offset);
        self
    }
    pub fn title(&mut self, title: String) -> &mut TestQuery {
        self.story_query.title = Some(title);
        self
    }
    pub fn medium(&mut self, medium: String) -> &mut TestQuery {
        self.story_query.medium = Some(medium);
        self
    }
    pub fn creator(&mut self, creator: String) -> &mut TestQuery {
        self.story_query.creator = Some(creator);
        self
    }
    pub fn username(&mut self, username: String) -> &mut TestQuery {
        self.username = Some(username);
        self
    }
    pub fn timestamp(&mut self, timestamp: DateTime<Utc>) -> &mut TestQuery {
        self.timestamp = Some(timestamp);
        self
    }
}
