use reqwest::StatusCode;
use serde_json::{json, Value};
use uuid::Uuid;

use crate::helpers::TestApp;

impl TestApp {
    pub async fn post_signup(&self, body: String) -> reqwest::Response {
        self.api_client
            .post(&format!("{}/signup", &self.address))
            .header("Content-Type", "application/json")
            .body(body)
            .send()
            .await
            .expect("Failed to execute request.")
    }
}

#[tokio::test]
async fn signup_returns_a_400_when_fields_are_present_but_invalid() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let test_cases = vec![
        (
            json!({"user": {"username": "", "password":"5stars" }}),
            "empty username",
        ),
        (
            json!({"user": {"username": "Dune", "password":"" }}),
            "empty password",
        ),
    ];
    for (body, description) in test_cases {
        // Act
        let response = app.post_signup(body.to_string()).await;

        // Assert
        assert_eq!(
            400,
            response.status().as_u16(),
            "The API did not return a 400 Bad Request when the payload was {}.",
            description
        );
    }

    app.teardown().await;
}

#[tokio::test]
async fn signup_return_user_details_after_correct_request() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act - Part 1 - Login
    let username = Uuid::new_v4().to_string();
    let signup_body = serde_json::json!({
        "user": {
            "username": username,
            "password": Uuid::new_v4().to_string()
        }
    });
    let response = app.post_signup(signup_body.to_string()).await;

    assert_eq!(response.status(), StatusCode::OK);

    let json: Value = response.json().await.expect("expected json response");
    assert_eq!(json["user"]["username"], username);

    app.teardown().await;
}
