use futures_lite::{stream, StreamExt};
use reqwest::StatusCode;
use serde_json::Value;

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
            .get(&format!("{}/emotions/{}", &self.address, icon_url))
            .send()
            .await
            .expect("Failed to execute request.")
    }
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
    assert_eq!(emotions.len(), 21);
    assert!(emotions
        .iter()
        .map(|x| x.as_str())
        .any(|x| x == Some("Joy")));
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
        assert_eq!(content_type, "SVG");
    }
    app.teardown().await;
}
