
use reqwest::StatusCode;
use serde_json::{json, Value};

use crate::helpers::{spawn_app, TestApp, TestUser};

impl TestApp {
    pub async fn post_review(&self, body: String, token: &str) -> reqwest::Response {
        self.api_client
            .post(&format!("{}/reviews", &self.address))
            .header("Content-Type", "application/json")
            .bearer_auth(token)
            .body(body)
            .send()
            .await
            .expect("Failed to execute request.")
    }
}

#[tokio::test]
async fn post_review_returns_unauth_when_logged_out() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;
    app.test_user.logout().await;

    // Act
    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
    let response = app.post_review(body.to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);
}

#[tokio::test]
async fn post_review_returns_unauth_when_using_valid_but_non_existant_user() {
    // Arrange
    let app = spawn_app().await;

    // create new user
    let user = TestUser::generate();
    // take token
    let token = user.store(&app).await;
    // delete user
    app.delete_user(&token).await;

    // Act
    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
    let response = app.post_review(body.to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);
}

#[tokio::test]
async fn post_review_persists_the_new_review() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
    let response = app.post_review(body.to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!("SELECT title, body FROM reviews",)
        .fetch_one(&app.db_pool)
        .await
        .expect("Failed to fetch saved subscription.");

    assert_eq!(saved.body, "5stars");
    assert_eq!(saved.title, "Dune");
}

#[tokio::test]
async fn post_review_returns_a_400_when_data_is_missing() {
    // Arrange
    let app = spawn_app().await;

    let token = app.test_user.login(&app).await;
    let test_cases = vec![
        (json!({"review": {"title": "Dune"} }), "missing the review"),
        (json!({ "review":{"body":"5stars"} }), "missing the title"),
        (json!({"review":{}}), "missing both title and review"),
    ];

    for (invalid_body, error_message) in test_cases {
        // Act
        let response = app.post_review(invalid_body.to_string(), &token).await;

        // Assert
        assert_eq!(
            400,
            response.status().as_u16(),
            // Additional customised error message on test failure
            "The API did not fail with 400 Bad Request when the payload was {}.",
            error_message
        );
    }
}

#[tokio::test]
async fn post_review_returns_a_400_when_fields_are_present_but_invalid() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    let test_cases = vec![
        (
            json!({"review": {"title": "", "body":"5stars" }}),
            "empty title",
        ),
        (
            json!({"review": {"title": "Dune", "body":"" }}),
            "empty review",
        ),
    ];
    for (body, description) in test_cases {
        // Act
        let response = app.post_review(body.to_string(), &token).await;

        // Assert
        assert_eq!(
            400,
            response.status().as_u16(),
            "The API did not return a 400 Bad Request when the payload was {}.",
            description
        );
    }
}

#[tokio::test]
async fn post_review_returns_json() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    let body = json!({"review": {"title": "Dune", "body":"5stars" }});

    // Act
    let response = app.post_review(body.to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json: Value = response.json().await.expect("expected json response");
    assert_eq!(json["review"]["body"], "5stars");
    assert_eq!(json["review"]["title"], "Dune");
}
