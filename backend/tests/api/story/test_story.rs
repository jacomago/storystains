use fake::{faker, Fake};
use reqwest::StatusCode;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};

use crate::helpers::TestApp;

pub fn story_relative_url_prefix() -> String {
    "/stories".to_string()
}

pub fn story_relative_url(slug: &str) -> String {
    format!("/stories/{}", slug)
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
    fn create_json(&self) -> Value {
        json!(
            {
                "story": {
                    "title": self.title,
                    "medium": self.medium,
                    "creator": self.creator
                }
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
