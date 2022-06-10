use reqwest::StatusCode;
use serde_json::{json, Value};

use crate::helpers::{spawn_app, TestApp, TestUser};


impl TestApp {

    pub async fn put_review(&self, slug: String, body: String, token: &str) -> reqwest::Response {
        self.api_client
            .put(&format!("{}/reviews/{}", &self.address, &slug))
            .header("Content-Type", "application/json")
            .bearer_auth(token)
            .body(body)
            .send()
            .await
            .expect("Failed to execute request.")
    }
}

#[tokio::test]
async fn put_review_returns_unauth_when_not_logged_in() {
    // Arrange
    let app = spawn_app().await;

    // Act
    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
    let response = app
        .put_review("dune".to_string(), body.to_string(), "")
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);
}

#[tokio::test]
async fn put_review_returns_a_200_for_valid_json_data() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
    app.post_review(body.to_string(), &token).await;
    let body = json!({"review": {"body":"3stars" }});
    let response = app
        .put_review("dune".to_string(), body.to_string(), &token)
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!("SELECT title, body FROM reviews",)
        .fetch_one(&app.db_pool)
        .await
        .expect("Failed to fetch saved subscription.");

    assert_eq!(saved.body, "3stars");
    assert_eq!(saved.title, "Dune");
}

#[tokio::test]
async fn put_review_returns_not_found_for_non_existant_review() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let response = app
        .put_review(
            "dune".to_string(),
            json!({"review": {"title": "Dune", "body":"5stars" }}).to_string(),
            &token,
        )
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::NOT_FOUND);
}

#[tokio::test]
async fn put_review_returns_bad_request_for_invalid_slug() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let response = app
        .put_review("a".repeat(257).to_string(), "".to_string(), &token)
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);
}

#[tokio::test]
async fn put_review_returns_a_400_when_fields_are_present_but_invalid() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
    app.post_review(body.to_string(), &token).await;

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
        let response = app
            .put_review("dune".to_string(), body.to_string(), &token)
            .await;

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
async fn put_review_returns_json() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
    app.post_review(body.to_string(), &token).await;

    let body = json!({"review": {"title": "Dune2", "body":"3stars" }});

    // Act
    let response = app
        .put_review("dune".to_string(), body.to_string(), &token)
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);
    let json: Value = response.json().await.expect("expected json response");
    assert_eq!(json["review"]["body"], "3stars");
    assert_eq!(json["review"]["title"], "Dune2");
}

#[tokio::test]
async fn put_review_only_allows_creator_to_modify() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
    app.post_review(body.to_string(), &token).await;

    let body = json!({"review": {"title": "Dune2", "body":"3stars" }});

    let new_user = TestUser::generate();
    let new_token = new_user.store(&app).await;

    // Act
    let response = app
        .put_review("dune".to_string(), body.to_string(), &new_token)
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::FORBIDDEN);
}
