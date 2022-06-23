use reqwest::{Method, StatusCode};

use crate::{
    auth::route_returns_unauth_when_not_logged_in,
    helpers::{TestApp, TestUser},
    review::test_review::TestReview,
};

use super::review_relative_url;

impl TestApp {
    pub async fn delete_review(&self, slug: &str, token: &str) -> reqwest::Response {
        self.api_client
            .delete(&format!("{}{}", &self.address, review_relative_url(slug)))
            .bearer_auth(token)
            .send()
            .await
            .expect("Failed to execute request.")
    }
}

#[tokio::test]
async fn delete_review_returns_unauth_when_not_logged_in() {
    route_returns_unauth_when_not_logged_in(&review_relative_url("slug"), Method::DELETE).await;
}

#[tokio::test]
async fn delete_review_returns_bad_request_for_invalid_title() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let response = app.delete_review(&"a".repeat(257), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);

    app.teardown().await;
}

#[tokio::test]
async fn delete_review_returns_a_200_for_valid_slug() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;
    let response = app.delete_review(review.slug(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!("SELECT title, body FROM reviews",)
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
    let token = app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;
    let response = app.delete_user(&token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!("SELECT title, body FROM reviews",)
        .fetch_optional(&app.db_pool)
        .await
        .expect("Query failed to execute.");

    assert!(saved.is_none());

    app.teardown().await;
}

#[tokio::test]
async fn delete_user_doesnt_delete_others_reviews() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;
    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;

    let other_user = TestUser::generate();
    let other_token = other_user.store(&app).await;
    let other_review = TestReview::generate(&other_user);
    other_review.store(&app, &other_token).await;

    // Act
    let response = app.delete_user(&token).await;

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
