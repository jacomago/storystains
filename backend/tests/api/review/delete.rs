use reqwest::{Method, StatusCode};

use crate::{
    auth::route_returns_unauth_when_not_logged_in,
    helpers::{TestApp, TestUser},
    review::test_review::TestReview,
};

use super::review_relative_url;

impl TestApp {
    pub async fn delete_review(&self, username: &str, slug: &str) -> reqwest::Response {
        self.api_client
            .delete(&format!(
                "{}{}",
                &self.address,
                review_relative_url(username, slug)
            ))
            .send()
            .await
            .expect("Failed to execute request.")
    }
}

#[tokio::test]
async fn delete_review_returns_unauth_when_not_logged_in() {
    route_returns_unauth_when_not_logged_in(
        |username: &str| review_relative_url(username, "slug"),
        Method::DELETE,
    )
    .await;
}

#[tokio::test]
async fn delete_review_returns_bad_request_for_invalid_title() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let response = app
        .delete_review(&app.test_user.username, &"a".repeat(257))
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);

    app.teardown().await;
}

#[tokio::test]
async fn delete_review_returns_a_200_for_valid_slug() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app).await;
    let response = app
        .delete_review(&app.test_user.username, review.slug())
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!("SELECT story_id, body FROM reviews",)
        .fetch_optional(&app.db_pool)
        .await
        .expect("Query failed to execute.");

    assert!(saved.is_none());

    app.teardown().await;
}

#[tokio::test]
async fn delete_user_deletes_reviews() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app).await;
    let response = app.delete_user().await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!("SELECT story_id, body FROM reviews",)
        .fetch_optional(&app.db_pool)
        .await
        .expect("Query failed to execute.");

    assert!(saved.is_none());

    app.teardown().await;
}

#[tokio::test]
#[ignore = "often fails in CI"]
async fn delete_user_doesnt_delete_others_reviews() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;
    let review = TestReview::generate(&app.test_user);
    review.store(&app).await;

    let other_user = TestUser::generate();
    other_user.store(&app).await;
    let other_review = TestReview::generate(&other_user);
    other_review.store(&app).await;

    // Act
    let response = app.delete_user().await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!(
        r#"
            SELECT id 
              FROM reviews,
                   users
             WHERE reviews.user_id = users.user_id
               AND users.username  = $1
        "#,
        other_user.username
    )
    .fetch_optional(&app.db_pool)
    .await
    .expect("Query failed to execute.");

    assert!(saved.is_some());

    app.teardown().await;
}
