use reqwest::StatusCode;

use crate::{emotion::helpers::TestEmotion, helpers::TestApp, review::TestReview};

impl TestApp {
    pub async fn delete_emotion(
        &self,
        slug: String,
        position: i32,
        token: &str,
    ) -> reqwest::Response {
        self.api_client
            .delete(&format!(
                "{}/reviews/{}/emotions/{}",
                &self.address, &slug, &position
            ))
            .bearer_auth(token)
            .send()
            .await
            .expect("Failed to execute request.")
    }
}

#[tokio::test]
async fn delete_review_emotion_returns_unauth_when_not_logged_in() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act
    let response = app.delete_emotion("dune".to_string(), 1, "").await;

    // Assert
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);

    app.teardown().await;
}

#[tokio::test]
async fn delete_review_emotion_returns_bad_request_for_invalid_position() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;
    let response = app.delete_emotion(review.slug(), 101, &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);

    app.teardown().await;
}

#[tokio::test]
async fn delete_review_emotion_returns_a_200_for_valid_position() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;
    let emotion = TestEmotion::generate();
    emotion.store(&app, &token, review.slug()).await;
    let response = app
        .delete_emotion(review.slug(), emotion.position, &token)
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!("SELECT title, body FROM reviews",)
        .fetch_optional(&app.db_pool)
        .await
        .expect("Query failed to execute.");

    assert!(saved.is_none());

    app.teardown().await;
}
