use reqwest::StatusCode;
use serde_json::{json, Value};

use crate::{helpers::TestApp, users::TestUser};

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
async fn login_returns_bad_request_for_incorrect_credentials() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act
    let login_body = json!({
        "user": {
            "username": "random-username",
            "password": "random-password"
        }
    });
    let response = app.post_login(login_body.to_string()).await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);

    app.teardown().await;
}

#[tokio::test]
async fn login_returns_bad_request_for_deleted_user() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // create new user
    let user = TestUser::generate();
    // store user
    user.store(&app).await;
    // delete user
    app.delete_logged_in_user().await;

    // Act
    let response = app.post_login(user.to_json()).await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);

    app.teardown().await;
}

#[tokio::test]
async fn login_returns_user_details_after_correct_request() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act - Part 1 - Login
    let login_body = json!({
        "user": {
            "username": &app.test_user.username,
            "password": &app.test_user.password
        }
    });
    let response = app.post_login(login_body.to_string()).await;

    assert_eq!(response.status(), StatusCode::OK);

    let json: Value = response.json().await.expect("expected json response");
    assert_eq!(json["user"]["username"], app.test_user.username);

    app.teardown().await;
}
