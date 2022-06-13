use rand::Rng;
use reqwest::StatusCode;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};

use crate::helpers::{long_form, TestApp};

fn emotions() -> Vec<String> {
    vec![
        "Anger".to_string(),
        "Disgust".to_string(),
        "Fear".to_string(),
        "Joy".to_string(),
        "Sadness".to_string(),
        "Surprise".to_string(),
        "Outrage".to_string(),
        "Trapped".to_string(),
        "Cruelty".to_string(),
        "Betrayl".to_string(),
        "WhatThe".to_string(),
        "Horror".to_string(),
        "Eww".to_string(),
        "PainEmpathy".to_string(),
        "YouAteIt".to_string(),
        "Desperation".to_string(),
        "Devastation".to_string(),
        "Spooked".to_string(),
        "FaintHope".to_string(),
        "Amazement".to_string(),
        "Disappointment".to_string(),
    ]
}

#[derive(Debug, Serialize, Deserialize)]
pub struct TestEmotionPart {
    emotion: String,
    position: i32,
}

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

    pub fn generate() -> Self {
        let v = emotions();
        Self {
            emotion: v[rand::thread_rng().gen_range(0..v.len())].to_string(),
            position: rand::thread_rng().gen_range(0..100),
            notes: long_form(),
        }
    }

    pub fn part(&self) -> TestEmotionPart {
        TestEmotionPart {
            emotion: self.emotion.to_string(),
            position: self.position,
        }
    }

    pub async fn store(&self, app: &TestApp, token: &str, review_slug: String) {
        let body = self.create_json();
        // Act
        let response = app
            .post_emotion(token, &review_slug, body.to_string())
            .await;

        // Assert
        assert_eq!(response.status(), StatusCode::OK);
    }
}
