use reqwest::StatusCode;
use serde_json::{json, Value};

use crate::{
    helpers::{spawn_app, TestApp},
    review::TestReview,
};

impl TestApp {
    pub async fn get_emotions(&self) -> reqwest::Response {
        self.api_client
            .get(&format!("{}/emotions", &self.address))
            .send()
            .await
            .expect("Failed to execute request.")
    }

    pub async fn post_emotion(
        &self,
        token: &str,
        review_slug: &str,
        body: String,
    ) -> reqwest::Response {
        self.api_client
            .post(&format!(
                "{}/reviews/{}/emotions",
                &self.address, &review_slug
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
async fn get_emotions_returns_list() {
    // Arrange
    let app = spawn_app().await;

    // Act
    let response = app.get_emotions().await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json_page = response.text().await.unwrap();
    let json: Value = serde_json::from_str(&json_page).unwrap();

    assert!(json["emotions"].is_array());

    let emotions = json["emotions"].as_array().unwrap();
    assert_eq!(emotions.len(), 21);
    assert!(emotions
        .iter()
        .map(|x| x.as_str())
        .any(|x| x == Some("Joy")));
}

#[tokio::test]
async fn post_review_emotion_to_review_unauth_when_not_logged_in() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;
    let json: Value = json!({
        "review_emotion": {
            "emotion": "Joy",
            "position": 100_i32,
            "notes": "None"
        }
    });
    let response = app.post_emotion("", &review.slug(), json.to_string()).await;

    // Assert
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);
}

#[tokio::test]
async fn post_review_emotion_to_review_unauth_when_logged_out() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;
    let json: Value = json!({
        "review_emotion": {
            "emotion": "Joy",
            "position": 100_i32,
            "notes": "None"
        }
    });
    app.test_user.logout().await;

    let response = app
        .post_emotion(&token, &review.slug(), json.to_string())
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);
}

#[tokio::test]
async fn post_review_emotion_returns_a_400_when_data_is_missing() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;
    let test_cases = vec![
        (
            json!({"review_emotion": {"emotion": "Joy"} }),
            "missing the position",
        ),
        (
            json!({ "review_emotion":{"position":100_i32} }),
            "missing the emotion",
        ),
        (
            json!({"review_emotion":{}}),
            "missing both title and review",
        ),
    ];

    for (invalid_body, error_message) in test_cases {
        // Act
        let response = app
            .post_emotion(&token, &review.slug(), invalid_body.to_string())
            .await;

        // Assert
        assert_eq!(
            400,
            response.status().as_u16(),
            // Additional customised error message on test failure
            "The API did not fail with 400 Bad Request when the payload was {}.",
            error_message
        );
    }
}

#[tokio::test]
async fn post_review_emotion_persists_the_new_review() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;
    let body = json!({
        "review_emotion": {
            "emotion": "Joy",
            "position": 100_i32,
            "notes": "None"
        }
    });
    let response = app
        .post_emotion(&token, &review.slug(), body.to_string())
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!("SELECT emotion_id, position, notes FROM review_emotions",)
        .fetch_one(&app.db_pool)
        .await
        .expect("Failed to fetch saved review emotions.");

    assert_eq!(saved.emotion_id, 4);
    assert_eq!(saved.position, 100_i32);
    assert_eq!(saved.notes, Some("None".to_string()));
}

#[tokio::test]
async fn post_review_emotion_returns_a_400_when_fields_are_present_but_invalid() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;

    let test_cases = vec![
        (
            json!({"review_emotion": {"emotion": "", "position":100_i32 }}),
            "empty emotion",
        ),
        (
            json!({"review_emotion": {"emotion": "Joy", "position":101_i32 }}),
            "empty incorrect position numer format",
        ),
    ];
    for (body, description) in test_cases {
        // Act
        let response = app
            .post_emotion(&token, &review.slug(), body.to_string())
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
async fn post_review_emotion_returns_json() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    let review = TestReview::generate(&app.test_user);
    review.store(&app, &token).await;

    let body = json!({
        "review_emotion": {
            "emotion": "Joy",
            "position": 100_i32,
            "notes": "None"
        }
    });

    // Act
    let response = app.post_review(body.to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json: Value = response.json().await.expect("expected json response");
    assert_eq!(json["review_emotion"]["emotion"], "Joy");
    assert_eq!(json["review_emotion"]["position"], 100_i32);
    assert_eq!(json["review_emotion"]["notes"], "None");
}
