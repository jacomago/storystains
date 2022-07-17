use reqwest::StatusCode;

use crate::{helpers::TestApp, review::test_review::TestReview};

use super::{review_relative_url, test_review::TestReviewResponse};

impl TestApp {
    pub async fn get_review(&self, username: &str, slug: &str) -> reqwest::Response {
        self.api_client
            .get(&format!(
                "{}{}",
                &self.address,
                review_relative_url(username, slug)
            ))
            .send()
            .await
            .expect("Failed to execute request.")
    }

    pub async fn get_review_json(&self, username: &str, slug: &str) -> String {
        self.get_review(username, slug).await.text().await.unwrap()
    }
}

#[tokio::test]
async fn get_review_logged_in_returns_json() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    let review = TestReview::generate(&app.test_user);
    review.store(&app).await;
    review.store_emotions(&app).await;

    let json_page = app
        .get_review_json(&app.test_user.username, review.slug())
        .await;
    let response_review: TestReviewResponse = serde_json::from_str(&json_page).unwrap();
    assert_eq!(review, response_review.review);

    app.teardown().await;
}

#[tokio::test]
async fn get_review_logged_out_returns_json() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    let review = TestReview::generate(&app.test_user);
    review.store(&app).await;
    review.store_emotions(&app).await;

    app.test_user.logout(&app).await;

    let json_page = app
        .get_review_json(&app.test_user.username, review.slug())
        .await;
    let response_review: TestReviewResponse = serde_json::from_str(&json_page).unwrap();
    assert_eq!(review, response_review.review);

    app.teardown().await;
}

#[tokio::test]
async fn get_review_returns_not_found_for_non_existant_review() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act
    let response = app.get_review(&app.test_user.username, "dune").await;

    // Assert
    assert_eq!(response.status(), StatusCode::NOT_FOUND);

    app.teardown().await;
}

#[tokio::test]
async fn get_review_returns_bad_request_for_invalid_title() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act
    let response = app
        .get_review(&app.test_user.username, &"a".repeat(257))
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);

    app.teardown().await;
}
