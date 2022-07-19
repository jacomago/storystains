use reqwest::{Method, StatusCode};
use serde_json::{json, Value};

use crate::{
    auth::route_returns_unauth_when_not_logged_in, helpers::TestApp, review::TestReview,
    review_emotion::test_review_emotion::TestReviewEmotion, users::TestUser,
};

use super::test_review_emotion::review_emotion_relative_url;

impl TestApp {
    pub async fn put_emotion(
        &self,
        username: &str,
        slug: &str,
        position: i32,
        body: String,
    ) -> reqwest::Response {
        self.api_client
            .put(&format!(
                "{}{}",
                &self.address,
                &review_emotion_relative_url(username, slug, &position),
            ))
            .header("Content-Type", "application/json")
            .body(body)
            .send()
            .await
            .expect("Failed to execute request.")
    }
}

#[tokio::test]
async fn put_review_emotion_returns_unauth_when_not_logged_in() {
    route_returns_unauth_when_not_logged_in(
        |username| review_emotion_relative_url(username, "slug", &1),
        Method::PUT,
    )
    .await;
}

#[tokio::test]
async fn put_review_emotion_stores_new_emotion() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app).await;
    let emotion = TestReviewEmotion::generate(None);
    emotion.store(&app, review.slug()).await;
    let body = json!({"review_emotion": {"emotion":"Anger" }});
    let response = app
        .put_emotion(
            &app.test_user.username,
            review.slug(),
            emotion.position,
            body.to_string(),
        )
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

    assert_eq!(saved.name, "Anger".to_string());
    assert_eq!(saved.notes, Some(emotion.notes.to_string()));
    app.teardown().await;
}

#[tokio::test]
async fn put_review_emotion_stores_new_position() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app).await;
    let emotion = TestReviewEmotion::generate(None);
    emotion.store(&app, review.slug()).await;
    let new_position = if emotion.position == 57 { 56 } else { 57 };
    let body = json!({"review_emotion": {"position":new_position }});
    let response = app
        .put_emotion(
            &app.test_user.username,
            review.slug(),
            emotion.position,
            body.to_string(),
        )
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

    assert_eq!(saved.position, new_position);
    assert_eq!(saved.notes, Some(emotion.notes.to_string()));
    app.teardown().await;
}

#[tokio::test]
async fn put_review_emotion_stores_new_data() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app).await;
    let emotion = TestReviewEmotion::generate(None);
    emotion.store(&app, review.slug()).await;
    let new_position = if emotion.position == 57 { 56 } else { 57 };
    let body = json!({"review_emotion": {"emotion":"Anger" , "position": new_position}});
    let response = app
        .put_emotion(
            &app.test_user.username,
            review.slug(),
            emotion.position,
            body.to_string(),
        )
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

    assert_eq!(saved.position, new_position);
    assert_eq!(saved.name, "Anger".to_string());
    assert_eq!(saved.notes, Some(emotion.notes.to_string()));
    app.teardown().await;
}

#[tokio::test]
async fn put_review_emotion_stores_new_data_with_many_emotions() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app).await;

    let emotion = TestReviewEmotion::generate(None);
    emotion.store(&app, review.slug()).await;
    let emotion = TestReviewEmotion::generate(None);
    emotion.store(&app, review.slug()).await;
    let emotion = TestReviewEmotion::generate(None);
    emotion.store(&app, review.slug()).await;

    let new_position = if emotion.position == 57 { 56 } else { 57 };

    let body = json!({"review_emotion": {"emotion":"Anger" , "position": new_position}});

    let response = app
        .put_emotion(
            &app.test_user.username,
            review.slug(),
            emotion.position,
            body.to_string(),
        )
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!(
        r#"
            SELECT name, position, notes 
              FROM review_emotions, emotions 
             WHERE review_emotions.emotion_id = emotions.id
               AND position = $1
        "#,
        new_position,
    )
    .fetch_one(&app.db_pool)
    .await
    .expect("Failed to fetch saved review emotions.");

    assert_eq!(saved.position, new_position);
    assert_eq!(saved.name, "Anger".to_string());
    assert_eq!(saved.notes, Some(emotion.notes.to_string()));
    app.teardown().await;
}

#[tokio::test]
async fn put_review_emotion_returns_not_found_for_non_existant_review() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app).await;
    let emotion = TestReviewEmotion::generate(None);
    let body = json!({"review_emotion": {"emotion":"Anger" }});
    let response = app
        .put_emotion(
            &app.test_user.username,
            review.slug(),
            emotion.position,
            body.to_string(),
        )
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::NOT_FOUND);
    app.teardown().await;
}

#[tokio::test]
async fn put_review_emotion_returns_bad_request_for_invalid_position() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app).await;
    let response = app
        .put_emotion(&app.test_user.username, review.slug(), -1, "".to_string())
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);
    app.teardown().await;
}

#[tokio::test]
async fn put_review_emotion_returns_a_400_when_fields_are_present_but_invalid() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    let review = TestReview::generate(&app.test_user);
    review.store(&app).await;

    let emotion = TestReviewEmotion::generate(None);
    emotion.store(&app, review.slug()).await;

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
            .put_emotion(
                &app.test_user.username,
                review.slug(),
                emotion.position,
                body.to_string(),
            )
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
    app.test_user.login(&app).await;

    let review = TestReview::generate(&app.test_user);
    review.store(&app).await;

    let emotion = TestReviewEmotion::generate(None);
    emotion.store(&app, review.slug()).await;

    let body = json!({"review_emotion": {"emotion":"Anger" }});

    // Act
    let response = app
        .put_emotion(
            &app.test_user.username,
            review.slug(),
            emotion.position,
            body.to_string(),
        )
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);
    let json: Value = response.json().await.expect("expected json response");
    assert_eq!(json["review_emotion"]["emotion"]["name"], "Anger");
    assert_eq!(json["review_emotion"]["position"], emotion.position);
    assert_eq!(json["review_emotion"]["notes"], emotion.notes);
    app.teardown().await;
}

#[tokio::test]
async fn put_review_emotion_only_allows_creator_to_modify_even_if_admin() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    let review = TestReview::generate(&app.test_user);
    review.store(&app).await;

    let emotion = TestReviewEmotion::generate(None);
    emotion.store(&app, review.slug()).await;

    let body = json!({"review_emotion": {"emotion":"Anger" }});

    let new_user = TestUser::generate();
    new_user.store(&app).await;
    new_user.set_admin(&app).await;

    // Act
    let response = app
        .put_emotion(
            &app.test_user.username,
            review.slug(),
            emotion.position,
            body.to_string(),
        )
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::FORBIDDEN);
    app.teardown().await;
}
