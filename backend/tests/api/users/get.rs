use reqwest::StatusCode;
use serde_json::Value;

use crate::helpers::TestApp;

impl TestApp {
    pub async fn get_logged_in_user(&self) -> reqwest::Response {
        self.api_client
            .get(&format!("{}/user", &self.address))
            .send()
            .await
            .expect("Failed to execute request.")
    }
}

#[tokio::test]
async fn no_result_when_not_logged_in() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act
    let response = reqwest::Client::builder()
        .redirect(reqwest::redirect::Policy::none())
        .build()
        .unwrap()
        .get(&format!("{}/user", &app.address))
        .send()
        .await
        .expect("Failed to execute request.");

    // Assert
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);

    app.teardown().await;
}

#[tokio::test]
async fn get_user_response_when_logged_in() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act
    let response = app.get_logged_in_user().await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json: Value = response.json().await.unwrap();
    assert_eq!(json["user"]["username"], app.test_user.username);

    app.teardown().await;
}
