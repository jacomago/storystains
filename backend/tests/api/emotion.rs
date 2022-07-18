use reqwest::StatusCode;
use serde_json::Value;
use storystains::api::EMOTION_STRINGS;

use crate::helpers::TestApp;

impl TestApp {
    pub async fn get_emotions(&self) -> reqwest::Response {
        self.api_client
            .get(&format!("{}/emotions", &self.address))
            .send()
            .await
            .expect("Failed to execute request.")
    }
    pub async fn get_image(&self, icon_url: &str) -> reqwest::Response {
        self.api_client
            .get(&format!(
                "{}{}",
                &self.address.strip_suffix("/api").unwrap(),
                icon_url
            ))
            .send()
            .await
            .expect("Failed to execute request.")
    }
}

#[derive(serde::Serialize, serde::Deserialize)]
pub struct EmotionsResponse {
    emotions: Vec<TestEmotion>,
}

#[derive(serde::Serialize, serde::Deserialize, Debug, Clone)]
pub struct TestEmotion {
    pub name: String,
    pub description: String,
    pub icon_url: String,
    pub joy: i32,
    pub sadness: i32,
    pub anger: i32,
    pub disgust: i32,
    pub surprise: i32,
    pub fear: i32,
}

#[tokio::test]
async fn get_emotions_returns_list() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act
    let response = app.get_emotions().await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json_page = response.text().await.unwrap();
    let json: Value = serde_json::from_str(&json_page).unwrap();

    assert!(json["emotions"].is_array());

    let emotions = json["emotions"].as_array().unwrap();
    assert_eq!(emotions.len(), EMOTION_STRINGS.len());
    // TODO write more efficient version
    for e in EMOTION_STRINGS {
        assert!(emotions.iter().any(|x| x["name"] == e));
    }
    app.teardown().await;
}

#[tokio::test]
async fn get_emotion_image_returns_svg() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act
    let response = app.get_emotions().await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json_page = response.text().await.unwrap();
    let json: Value = serde_json::from_str(&json_page).unwrap();

    assert!(json["emotions"].is_array());

    let emotions = json["emotions"].as_array().unwrap();
    for emotion in emotions {
        let response = app.get_image(emotion["icon_url"].as_str().unwrap()).await;
        assert_eq!(response.status(), StatusCode::OK);
        let content_type: &str = response.headers()["Content-Type"].to_str().unwrap();
        assert_eq!(content_type, "image/svg+xml");
    }
    app.teardown().await;
}
