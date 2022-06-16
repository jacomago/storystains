use rand::Rng;
use reqwest::StatusCode;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use storystains::api::emotions;

use crate::helpers::{long_form, TestApp};

#[derive(Debug, Serialize, Deserialize)]
pub struct TestEmotionResponse {
    pub review_emotion: TestEmotion,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct TestEmotion {
    pub emotion: String,
    pub position: i32,
    pub notes: String,
}

impl TestEmotion {
    fn create_json(&self) -> Value {
        json!({"review_emotion": {
            "emotion": self.emotion.to_string(),
            "position":self.position,
            "notes": self.notes.to_string()
        }})
    }

    pub fn generate(position: Option<i32>) -> Self {
        let v = emotions();
        Self {
            emotion: v[rand::thread_rng().gen_range(0..v.len())].to_string(),
            position: position.unwrap_or_else(|| rand::thread_rng().gen_range(0..100)),
            notes: long_form(),
        }
    }

    pub async fn store(&self, app: &TestApp, token: &str, review_slug: &str) {
        let body = self.create_json();
        // Act
        let response = app.post_emotion(token, review_slug, body.to_string()).await;

        // Assert
        assert_eq!(response.status(), StatusCode::OK);
    }
}

impl PartialEq for TestEmotion {
    fn eq(&self, other: &Self) -> bool {
        self.emotion == other.emotion
            && self.position == other.position
            && self.notes == other.notes
    }
}
