use chrono::{DateTime, Utc};
use reqwest::StatusCode;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};

use crate::{
    helpers::{long_form, TestApp, TestUser},
    review_emotion::test_review_emotion::TestReviewEmotion,
    story::TestStory,
};

pub fn review_relative_url(username: &str, slug: &str) -> String {
    format!("/reviews/{}/{}", username, slug)
}

pub fn review_relative_url_prefix() -> String {
    "/reviews".to_string()
}

#[derive(Debug, Serialize, Deserialize)]
pub struct TestReviewResponse {
    pub review: TestReview,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct TestReview {
    story: TestStory,
    body: String,
    slug: String,
    created_at: DateTime<Utc>,
    updated_at: DateTime<Utc>,
    emotions: Option<Vec<TestReviewEmotion>>,
    user: TestUserProfile,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct TestUserProfile {
    username: String,
}

impl TestReview {
    fn create_json(&self) -> Value {
        json!({"review": {"title": self.story.title.to_string(), "body":self.body.to_string()}})
    }

    pub fn generate(user: &TestUser) -> Self {
        let story = TestStory::generate();
        Self {
            story: story.clone(),
            body: long_form(),
            slug: story.title,
            created_at: Utc::now(),
            updated_at: Utc::now(),
            emotions: Some(
                (1..4)
                    .map(|i| TestReviewEmotion::generate(Some(i * 10)))
                    .collect(),
            ),
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

    pub async fn store_emotions(&self, app: &TestApp, token: &str) {
        for e in self.emotions.as_ref().unwrap() {
            e.store_by_user(app, &app.test_user, token, &self.slug)
                .await;
        }
    }

    pub async fn store_emotions_by_user(&self, app: &TestApp, user: &TestUser, token: &str) {
        for e in self.emotions.as_ref().unwrap() {
            e.store_by_user(app, user, token, &self.slug).await;
        }
    }

    pub fn slug(&self) -> &str {
        &self.slug
    }

    pub fn title(&self) -> String {
        self.story.title.to_string()
    }
}

impl PartialEq for TestReview {
    fn eq(&self, other: &Self) -> bool {
        self.story == other.story
            && self.body == other.body
            && self.slug == other.slug
            && 10 > (self.created_at - other.created_at).num_seconds()
            && 10 > (self.updated_at - other.updated_at).num_seconds()
            && self.user.username == other.user.username
            && self.emotions == other.emotions
    }
}
