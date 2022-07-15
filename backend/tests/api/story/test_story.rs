use fake::{faker, Fake};
use reqwest::StatusCode;
use serde_json::{json, Value};

use crate::helpers::TestApp;

pub fn story_relative_url_prefix() -> String {
    "/stories".to_string()
}

#[derive(Debug, serde::Serialize, serde::Deserialize)]
pub struct TestStoryResponse {
    pub story: TestStory,
}
#[derive(Debug, serde::Serialize, serde::Deserialize, Clone)]
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

#[derive(Debug, serde::Serialize, serde::Deserialize, Clone)]
pub struct TestStoryQuery {
    pub title: Option<String>,
    pub medium: Option<String>,
    pub creator: Option<String>,
}

impl TestStoryQuery {
    pub fn new() -> Self {
        TestStoryQuery {
            title: None,
            medium: None,
            creator: None,
        }
    }
}
