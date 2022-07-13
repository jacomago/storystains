use fake::{faker, Fake};
use reqwest::StatusCode;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};

use crate::helpers::TestApp;

pub fn story_relative_url_prefix() -> String {
    "/stories".to_string()
}

#[derive(Debug, Serialize, Deserialize)]
pub struct TestStoryResponse {
    pub story: TestStory,
}
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct TestStory {
    pub title: String,
    pub creator: String,
    pub medium: String,
}

impl PartialEq for TestStory {
    fn eq(&self, other: &Self) -> bool {
        self.title == other.title && self.creator == other.creator && self.medium == other.medium
    }
}

impl TestStory {
    pub fn create_inner_json(&self) -> Value {
        json!(
            {
                "title": self.title,
                "medium": self.medium,
                "creator": self.creator
            }
        )
    }
    pub fn create_json(&self) -> Value {
        json!(
            {
                "story": self.create_inner_json()
            }
        )
    }

    pub fn generate() -> Self {
        TestStory {
            title: faker::lorem::en::Word().fake(),
            creator: faker::name::en::Name().fake(),
            medium: "Book".to_string(),
        }
    }

    pub async fn store(&self, app: &TestApp, token: &str) {
        let body = self.create_json();
        // Act
        let response = app.post_story(body.to_string(), token).await;

        // Assert
        assert_eq!(response.status(), StatusCode::OK);
    }
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct TestQuery {
    limit: Option<i32>,
    title: Option<String>,
    medium: Option<String>,
    creator: Option<String>,
}

impl TestQuery {
    pub fn new() -> Self {
        TestQuery {
            limit: None,
            title: None,
            medium: None,
            creator: None,
        }
    }
    pub fn limit(&mut self, limit: i32) -> &mut TestQuery {
        self.limit = Some(limit);
        self
    }
    pub fn title(&mut self, title: String) -> &mut TestQuery {
        self.title = Some(title);
        self
    }
    pub fn medium(&mut self, medium: String) -> &mut TestQuery {
        self.title = Some(medium);
        self
    }
    pub fn creator(&mut self, creator: String) -> &mut TestQuery {
        self.title = Some(creator);
        self
    }
}
