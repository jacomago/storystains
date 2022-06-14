use reqwest::StatusCode;
use serde_json::{json, Value};

use crate::{
    review_emotion::helpers::TestEmotion,
    helpers::{TestApp, TestUser},
    review::TestReview,
};

impl TestApp {
    pub async fn put_emotion(
        &self,
        slug: String,
        position: i32,
        body: String,
        token: &str,
    ) -> reqwest::Response {
        self.api_client
            .put(&format!(
                "{}/reviews/{}/emotions/{}",
                &self.address, &slug, position
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
async fn put_review_emotion_returns_unauth_when_not_logged_in() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act
    let body = json!({"review_emotion": {"emotion": "Joy", "position":1_i32 }});
    let response = app
        .put_emotion("dune".to_string(), 1, body.to_string(), "")
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);
    app.teardown().await;
}

#[tokio::test]
async fn put_review_emotion_stores_new_data() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;
    let emotion = TestEmotion::generate();
    emotion.store(&app, &token, review.slug()).await;
    let body = json!({"review_emotion": {"emotion":"Anger" }});
    let response = app
        .put_emotion(review.slug(), emotion.position, body.to_string(), &token)
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!(
        r#"
            SELECT name, position, notes 
              FROM review_emotions, emotions 
             WHERE review_emotions.emotion_id = emotions.id
        "#,
    )
    .fetch_one(&app.db_pool)
    .await
    .expect("Failed to fetch saved review emotions.");

    assert_eq!(saved.name, Some("Anger".to_string()));
    assert_eq!(saved.notes, Some(emotion.notes.to_string()));
    app.teardown().await;
}

#[tokio::test]
async fn put_review_emotion_returns_not_found_for_non_existant_review() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;
    let emotion = TestEmotion::generate();
    let body = json!({"review_emotion": {"emotion":"Anger" }});
    let response = app
        .put_emotion(review.slug(), emotion.position, body.to_string(), &token)
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::NOT_FOUND);
    app.teardown().await;
}

#[tokio::test]
async fn put_review_emotion_returns_bad_request_for_invalid_position() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;
    let response = app
        .put_emotion(review.slug(), -1, "".to_string(), &token)
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);
    app.teardown().await;
}

#[tokio::test]
async fn put_review_emotion_returns_a_400_when_fields_are_present_but_invalid() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;

    let emotion = TestEmotion::generate();
    emotion.store(&app, &token, review.slug()).await;

    let test_cases = vec![
        (
            json!({"review_emotion": {"emotion": "",  }}),
            "empty emotion",
        ),
        (
            json!({"review_emotion": {"position":101_i32 }}),
            "empty incorrect position number format",
        ),
    ];
    for (body, description) in test_cases {
        // Act
        let response = app
            .put_emotion(review.slug(), emotion.position, body.to_string(), &token)
            .await;

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
async fn put_review_emotion_returns_json() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;

    let emotion = TestEmotion::generate();
    emotion.store(&app, &token, review.slug()).await;

    let body = json!({"review_emotion": {"emotion":"Anger" }});

    // Act
    let response = app
        .put_emotion(review.slug(), emotion.position, body.to_string(), &token)
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);
    let json: Value = response.json().await.expect("expected json response");
    assert_eq!(json["review_emotion"]["emotion"], "Anger");
    assert_eq!(json["review_emotion"]["position"], emotion.position);
    assert_eq!(json["review_emotion"]["notes"], emotion.notes);
    app.teardown().await;
}

#[tokio::test]
async fn put_review_emotion_only_allows_creator_to_modify() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;

    let emotion = TestEmotion::generate();
    emotion.store(&app, &token, review.slug()).await;

    let body = json!({"review_emotion": {"emotion":"Anger" }});

    let new_user = TestUser::generate();
    let new_token = new_user.store(&app).await;

    // Act
    let response = app
        .put_emotion(
            review.slug(),
            emotion.position,
            body.to_string(),
            &new_token,
        )
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::FORBIDDEN);
    app.teardown().await;
}
