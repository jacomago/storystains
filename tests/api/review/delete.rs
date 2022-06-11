use reqwest::StatusCode;

use crate::{
    helpers::{spawn_app, TestApp},
    review::helpers::TestReview,
};

impl TestApp {
    pub async fn delete_review(&self, slug: String, token: &str) -> reqwest::Response {
        self.api_client
            .delete(&format!("{}/reviews/{}", &self.address, &slug))
            .bearer_auth(token)
            .send()
            .await
            .expect("Failed to execute request.")
    }
}

#[tokio::test]
async fn delete_review_returns_unauth_when_not_logged_in() {
    // Arrange
    let app = spawn_app().await;

    // Act
    let response = app.delete_review("dune".to_string(), "").await;

    // Assert
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);
}

#[tokio::test]
async fn delete_review_returns_bad_request_for_invalid_title() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let response = app.delete_review("a".repeat(257).to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);
}

#[tokio::test]
async fn delete_review_returns_a_200_for_valid_slug() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate();
    review.store(&app, &token).await;
    let response = app.delete_review(review.slug(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!("SELECT title, body FROM reviews",)
        .fetch_optional(&app.db_pool)
        .await
        .expect("Query failed to execute.");

    assert!(saved.is_none());
}
