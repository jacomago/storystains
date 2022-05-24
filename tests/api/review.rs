use reqwest::StatusCode;
use serde_json::Value;

use crate::helpers::{assert_is_redirect_to, spawn_app};

#[tokio::test]
async fn post_review_persists_the_new_review() {
    // Arrange
    let app = spawn_app().await;

    // Act
    let body = "title=Dune&review=5stars";
    let response = app.post_review(body.into()).await;

    // Assert
    assert_is_redirect_to(&response, "/reviews/dune");

    let saved = sqlx::query!("SELECT title, review FROM reviews",)
        .fetch_one(&app.db_pool)
        .await
        .expect("Failed to fetch saved subscription.");

    assert_eq!(saved.review, "5stars");
    assert_eq!(saved.title, "Dune");
}

#[tokio::test]
async fn post_review_returns_a_400_when_data_is_missing() {
    // Arrange
    let app = spawn_app().await;
    let test_cases = vec![
        ("title=Dune", "missing the review"),
        ("review=5stars", "missing the title"),
        ("", "missing both title and review"),
    ];

    for (invalid_body, error_message) in test_cases {
        // Act
        let response = app.post_review(invalid_body.into()).await;

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
async fn post_review_returns_a_400_when_fields_are_present_but_invalid() {
    // Arrange
    let app = spawn_app().await;
    let test_cases = vec![
        ("title=&review=5stars", "empty title"),
        ("title=Dune&review=", "empty review"),
    ];
    for (body, description) in test_cases {
        // Act
        let response = app.post_review(body.into()).await;

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
async fn post_review_returns_redirected_json() {
    // Arrange
    let app = spawn_app().await;

    let body = "title=Dune&review=5stars";

    // Act
    let response = app.post_review(body.into()).await;

    // Assert
    assert_is_redirect_to(&response, "/reviews/dune");
    let json_page = app.get_review_json(format!("dune")).await;
    let json: Value = serde_json::from_str(&json_page).unwrap();
    assert_eq!(json["review"], "5stars");
    assert_eq!(json["title"], "Dune");
}

#[tokio::test]
async fn get_review_returns_not_found_for_non_existant_review() {
    // Arrange
    let app = spawn_app().await;

    // Act
    let response = app.get_review("dune".to_string()).await;

    // Assert
    assert_eq!(response.status(), StatusCode::NOT_FOUND);
}

#[tokio::test]
async fn get_review_returns_bad_request_for_invalid_title() {
    // Arrange
    let app = spawn_app().await;

    // Act
    let response = app.get_review("a".repeat(257).to_string()).await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);
}

#[tokio::test]
async fn put_review_returns_a_200_for_valid_form_data() {
    // Arrange
    let app = spawn_app().await;

    // Act
    let body = "title=Dune&review=5stars";
    app.post_review(body.into()).await;
    let body = "review=3stars";
    let response = app.put_review("dune".to_string(), body.into()).await;

    // Assert
    assert_is_redirect_to(&response, "/reviews/dune");

    let saved = sqlx::query!("SELECT title, review FROM reviews",)
        .fetch_one(&app.db_pool)
        .await
        .expect("Failed to fetch saved subscription.");

    assert_eq!(saved.review, "3stars");
    assert_eq!(saved.title, "Dune");
}

#[tokio::test]
async fn put_review_returns_not_found_for_non_existant_review() {
    // Arrange
    let app = spawn_app().await;

    // Act
    let response = app.put_review("dune".to_string(), "".to_string()).await;

    // Assert
    assert_eq!(response.status(), StatusCode::NOT_FOUND);
}

#[tokio::test]
async fn put_review_returns_bad_request_for_invalid_slug() {
    // Arrange
    let app = spawn_app().await;

    // Act
    let response = app
        .put_review("a".repeat(257).to_string(), "".to_string())
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);
}

#[tokio::test]
async fn put_review_returns_a_400_when_fields_are_present_but_invalid() {
    // Arrange
    let app = spawn_app().await;

    let body = "title=Dune&review=5stars";
    app.post_review(body.into()).await;

    let test_cases = vec![
        ("title=&review=3stars", "empty title"),
        ("title=Dune2&review=", "empty review"),
    ];
    for (body, description) in test_cases {
        // Act
        let response = app.put_review("dune".to_string(), body.into()).await;

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
async fn put_review_returns_redirected_json() {
    // Arrange
    let app = spawn_app().await;

    let body = "title=Dune&review=5stars";
    app.post_review(body.into()).await;

    let body = "title=Dune2&review=3stars";

    // Act
    let response = app.put_review("dune".to_string(), body.into()).await;

    // Assert
    assert_is_redirect_to(&response, "/reviews/dune2");
    let json_page = app.get_review_json(format!("dune2")).await;
    let json: Value = serde_json::from_str(&json_page).unwrap();
    assert_eq!(json["review"], "3stars");
    assert_eq!(json["title"], "Dune2");
}
