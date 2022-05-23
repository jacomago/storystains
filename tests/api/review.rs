use serde_json::Value;

use crate::helpers::{assert_is_redirect_to, spawn_app};

#[tokio::test]
async fn post_review_returns_a_200_for_valid_form_data() {
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
async fn post_review_persists_the_new_review() {
    // Arrange
    let app = spawn_app().await;

    let body = "title=Dune&review=5stars";

    // Act
    app.post_review(body.into()).await;

    let saved = sqlx::query!("SELECT title, review FROM reviews",)
        .fetch_one(&app.db_pool)
        .await
        .expect("Failed to fetch saved subscription.");

    assert_eq!(saved.title, "Dune");
    assert_eq!(saved.review, "5stars");
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
