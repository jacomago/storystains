use crate::{
    helpers::{long_form, TestApp, TestUser},
    review::review_relative_url,
};
use rand::Rng;
use reqwest::StatusCode;
use serde_json::{json, Value};
use storystains::api::{emotions, EmotionData};

pub fn review_emotion_relative_url_prefix(username: &str, slug: &str) -> String {
    format!("{}/emotions", review_relative_url(username, slug))
}
pub fn review_emotion_relative_url(username: &str, slug: &str, position: &i32) -> String {
    format!(
        "{}/emotions/{}",
        review_relative_url(username, slug),
        position
    )
}

#[derive(Debug, serde::Serialize, serde::Deserialize)]
pub struct TestReviewEmotionResponse {
    pub review_emotion: TestReviewEmotion,
}

#[derive(Debug, serde::Serialize, serde::Deserialize)]
pub struct TestReviewEmotion {
    pub emotion: EmotionData,
    pub position: i32,
    pub notes: String,
}

impl TestReviewEmotion {
    fn create_json(&self) -> Value {
        json!({"review_emotion": {
            "emotion": self.emotion.name,
            "position":self.position,
            "notes": self.notes.to_string()
        }})
    }

    pub fn generate(position: Option<i32>) -> Self {
        let v = emotions();
        Self {
            emotion: v[rand::thread_rng().gen_range(0..v.len())].into(),
            position: position.unwrap_or_else(|| rand::thread_rng().gen_range(0..100)),
            notes: long_form(),
        }
    }

    pub async fn store(&self, app: &TestApp, review_slug: &str) {
        let body = self.create_json();
        // Act
        let response = app
            .post_emotion(&app.test_user.username, review_slug, body.to_string())
            .await;

        // Assert
        assert_eq!(response.status(), StatusCode::OK);
    }

    pub async fn store_by_user(&self, app: &TestApp, user: &TestUser, review_slug: &str) {
        let body = self.create_json();
        // Act
        let response = app
            .post_emotion(&user.username, review_slug, body.to_string())
            .await;

        // Assert
        assert_eq!(response.status(), StatusCode::OK);
    }
}

impl PartialEq for TestReviewEmotion {
    fn eq(&self, other: &Self) -> bool {
        self.emotion == other.emotion
            && self.position == other.position
            && self.notes == other.notes
    }
}
