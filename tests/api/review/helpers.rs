use chrono::{DateTime, Utc};
use fake::{faker, Fake};
use reqwest::StatusCode;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};

use crate::{
    emotion::helpers::{TestEmotion, TestEmotionPart},
    helpers::{long_form, TestApp, TestUser},
};

#[derive(Debug, Serialize, Deserialize)]
pub struct TestReviewResponse {
    pub review: TestReview,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct TestReview {
    title: String,
    body: String,
    slug: String,
    created_at: DateTime<Utc>,
    updated_at: DateTime<Utc>,
    emotions: Option<Vec<TestEmotionPart>>,
    user: TestUserProfile,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct TestUserProfile {
    username: String,
}

impl TestReview {
    fn create_json(&self) -> Value {
        json!({"review": {"title": self.title.to_string(), "body":self.body.to_string()}})
    }

    pub fn generate(user: &TestUser) -> Self {
        let title: String = faker::lorem::en::Word().fake();
        Self {
            title: title.to_string(),
            body: long_form(),
            slug: title,
            created_at: Utc::now(),
            updated_at: Utc::now(),
            emotions: Some((1..4).map(|_| TestEmotion::generate().part()).collect()),
            user: TestUserProfile {
                username: user.username.to_string(),
            },
        }
    }

    pub async fn store(&self, app: &TestApp, token: &str) {
        let body = self.create_json();
        // Act
        let response = app.post_review(body.to_string(), token).await;

        // Assert
        assert_eq!(response.status(), StatusCode::OK);
    }

    pub fn slug(&self) -> String {
        self.slug.to_string()
    }
    pub fn title(&self) -> String {
        self.title.to_string()
    }
}

impl PartialEq for TestReview {
    fn eq(&self, other: &Self) -> bool {
        self.title == other.title
            && self.body == other.body
            && self.slug == other.slug
            && 10 > (self.created_at - other.created_at).num_seconds()
            && 10 > (self.updated_at - other.updated_at).num_seconds()
            && self.user.username == other.user.username
    }
}
