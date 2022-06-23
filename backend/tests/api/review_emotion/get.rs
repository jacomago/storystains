use reqwest::StatusCode;

use crate::{
    helpers::TestApp, review::TestReview, review_emotion::test_review_emotion::TestReviewEmotion,
};

use super::test_review_emotion::{review_emotion_relative_url, TestReviewEmotionResponse};

impl TestApp {
    pub async fn get_emotion(&self, slug: &str, position: i32) -> reqwest::Response {
        self.api_client
            .get(&format!(
                "{}{}",
                &self.address,
                &review_emotion_relative_url(slug, &position),
            ))
            .send()
            .await
            .expect("Failed to execute request.")
    }

    pub async fn get_emotion_json(&self, slug: &str, position: i32) -> String {
        self.get_emotion(slug, position).await.text().await.unwrap()
    }
}

#[tokio::test]
async fn get_review_logged_in_returns_json() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;

    let emotion = TestReviewEmotion::generate(None);
    emotion.store(&app, &token, review.slug()).await;

    let json_page = app.get_emotion_json(review.slug(), emotion.position).await;
    let response_emotion: TestReviewEmotionResponse = serde_json::from_str(&json_page).unwrap();
    assert_eq!(emotion, response_emotion.review_emotion);

    app.teardown().await;
}

#[tokio::test]
async fn get_review_logged_out_returns_json() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;

    let emotion = TestReviewEmotion::generate(None);
    emotion.store(&app, &token, review.slug()).await;

    app.test_user.logout().await;

    let json_page = app.get_emotion_json(review.slug(), emotion.position).await;
    let response_emotion: TestReviewEmotionResponse = serde_json::from_str(&json_page).unwrap();
    assert_eq!(emotion, response_emotion.review_emotion);

    app.teardown().await;
}

#[tokio::test]
async fn get_review_returns_not_found_for_non_existant_emotion() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;
    let response = app.get_emotion(review.slug(), 1).await;

    // Assert
    assert_eq!(response.status(), StatusCode::NOT_FOUND);

    app.teardown().await;
}

#[tokio::test]
async fn get_review_returns_bad_request_for_invalid_position() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;
    let response = app.get_emotion(review.slug(), 101).await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);

    app.teardown().await;
}
