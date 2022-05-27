use reqwest::StatusCode;
use serde_json::Value;

use crate::helpers::{spawn_app, TestApp};

impl TestApp {
    pub async fn post_login(&self, body: String) -> reqwest::Response {
        self.api_client
            .post(&format!("{}/login", &self.address))
            .header("Content-Type", "application/json")
            .body(body)
            .send()
            .await
            .expect("Failed to execute request.")
    }
}
#[tokio::test]
async fn bad_request_for_incorrect_credentials() {
    // Arrange
    let app = spawn_app().await;

    // Act
    let login_body = serde_json::json!({
        "user": {
            "username": "random-username",
            "password": "random-password"
        }
    });
    let response = app.post_login(login_body.to_string()).await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);
}

#[tokio::test]
async fn return_user_details_after_correct_request() {
    // Arrange
    let app = spawn_app().await;

    // Act - Part 1 - Login
    let login_body = serde_json::json!({
        "user": {
            "username": &app.test_user.username,
            "password": &app.test_user.password
        }
    });
    let response = app.post_login(login_body.to_string()).await;

    assert_eq!(response.status(), StatusCode::OK);

    let json: Value = response.json().await.expect("expected json response");
    assert_eq!(json["user"]["username"], app.test_user.username);
}
