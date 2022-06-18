use reqwest::StatusCode;

use crate::{
    helpers::{TestApp, TestUser},
    review::TestReview,
    review_emotion::test_review_emotion::TestReviewEmotion,
};

impl TestApp {
    pub async fn delete_emotion(
        &self,
        slug: &str,
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
    let response = app.delete_emotion("dune", 1, "").await;

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
    let emotion = TestReviewEmotion::generate(None);
    emotion.store(&app, &token, review.slug()).await;
    let response = app
        .delete_emotion(review.slug(), emotion.position, &token)
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!("SELECT emotion_id, position, notes FROM review_emotions",)
        .fetch_optional(&app.db_pool)
        .await
        .expect("Failed to fetch saved review emotions.");

    assert!(saved.is_none());

    app.teardown().await;
}

#[tokio::test]
async fn delete_review_deletes_emotions() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;
    review.store_emotions(&app, &token).await;
    let response = app.delete_review(review.slug(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!("SELECT emotion_id, position FROM review_emotions",)
        .fetch_optional(&app.db_pool)
        .await
        .expect("Query failed to execute.");

    assert!(saved.is_none());

    app.teardown().await;
}

#[tokio::test]
async fn delete_user_deletes_review_emotions() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;
    review.store_emotions(&app, &token).await;
    let response = app.delete_user(&token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!("SELECT emotion_id, position FROM review_emotions",)
        .fetch_optional(&app.db_pool)
        .await
        .expect("Query failed to execute.");

    assert!(saved.is_none());

    app.teardown().await;
}

#[tokio::test]
async fn delete_user_doesnt_delete_others_emotions() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;
    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;
    review.store_emotions(&app, &token).await;

    let other_user = TestUser::generate();
    let other_token = other_user.store(&app).await;
    let other_review = TestReview::generate(&other_user);
    other_review.store(&app, &other_token).await;
    other_review.store_emotions(&app, &other_token).await;

    // Act
    let response = app.delete_user(&token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!(
        r#"
            SELECT emotion_id, position 
              FROM review_emotions,
                   reviews,
                   users
             WHERE review_id       = reviews.id
               AND reviews.user_id = users.user_id
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
