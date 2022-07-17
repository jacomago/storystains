use reqwest::StatusCode;
use serde_json::{json, Value};
use uuid::Uuid;

use crate::helpers::{TestApp, TestUser};

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

    pub async fn post_signup(&self, body: String) -> reqwest::Response {
        self.api_client
            .post(&format!("{}/signup", &self.address))
            .header("Content-Type", "application/json")
            .body(body)
            .send()
            .await
            .expect("Failed to execute request.")
    }

    pub async fn delete_user(&self) -> reqwest::Response {
        self.api_client
            .delete(&format!("{}/users", &self.address))
            .header("Content-Type", "application/json")
            .send()
            .await
            .expect("Failed to execute request.")
    }
    pub async fn post_logout(&self) -> reqwest::Response {
        self.api_client
            .post(&format!("{}/users/logout", &self.address))
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
    app.delete_user().await;

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

#[tokio::test]
async fn delete_user_deletes_user() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // create new user
    let user = TestUser::generate();
    // store user
    user.store(&app).await;
    // delete user
    app.delete_user().await;

    // Act
    app.delete_user().await;

    let saved = sqlx::query!(
        "SELECT user_id FROM users WHERE username = $1",
        user.username
    )
    .fetch_optional(&app.db_pool)
    .await
    .expect("Failed to fetch saved data.");

    // Assert
    assert!(saved.is_none());

    app.teardown().await;
}
