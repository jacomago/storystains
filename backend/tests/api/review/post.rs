use reqwest::{Method, StatusCode};
use serde_json::{json, Value};

use crate::{
    auth::{
        route_returns_unauth_when_logged_out, route_returns_unauth_when_not_logged_in,
        route_returns_unauth_when_using_valid_but_non_existant_user,
    },
    helpers::{TestApp, TestUser},
};

use super::review_relative_url_prefix;

impl TestApp {
    pub async fn post_review(&self, body: String, token: &str) -> reqwest::Response {
        self.api_client
            .post(&format!(
                "{}{}",
                &self.address,
                review_relative_url_prefix()
            ))
            .header("Content-Type", "application/json")
            .bearer_auth(token)
            .body(body)
            .send()
            .await
            .expect("Failed to execute request.")
    }
}

#[tokio::test]
async fn post_review_returns_unauth_when_not_logged_in() {
    route_returns_unauth_when_not_logged_in(|_| review_relative_url_prefix(), Method::POST).await;
}

#[tokio::test]
async fn post_review_returns_unauth_when_logged_out() {
    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
    route_returns_unauth_when_logged_out(|_| review_relative_url_prefix(), Method::POST, body)
        .await;
}

#[tokio::test]
async fn post_review_returns_unauth_when_using_valid_but_non_existant_user() {
    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
    route_returns_unauth_when_using_valid_but_non_existant_user(
        |_| review_relative_url_prefix(),
        Method::POST,
        body,
    )
    .await;
}

#[tokio::test]
async fn post_review_persists_the_new_review() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
    let response = app.post_review(body.to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved =
        sqlx::query!("SELECT (select title from stories where id = story_id), body FROM reviews",)
            .fetch_one(&app.db_pool)
            .await
            .expect("Failed to fetch saved data.");

    assert_eq!(saved.body, "5stars");
    assert_eq!(saved.title, Some("Dune".to_string()));
    app.teardown().await;
}

#[tokio::test]
async fn post_review_returns_a_400_when_data_is_missing() {
    // Arrange
    let app = TestApp::spawn_app().await;

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
    app.teardown().await;
}

#[tokio::test]
async fn post_review_returns_a_400_when_fields_are_present_but_invalid() {
    // Arrange
    let app = TestApp::spawn_app().await;
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
    app.teardown().await;
}

#[tokio::test]
async fn post_review_returns_json() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    let body = json!({"review": {"title": "Dune", "body":"5stars" }});

    // Act
    let response = app.post_review(body.to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json: Value = response.json().await.expect("expected json response");
    assert_eq!(json["review"]["body"], "5stars");
    assert_eq!(json["review"]["story"]["title"], "Dune");
    app.teardown().await;
}
