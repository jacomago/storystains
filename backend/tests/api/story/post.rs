use reqwest::{Method, StatusCode};
use serde_json::{json, Value};

use crate::{
    auth::{
        route_returns_unauth_when_logged_out, route_returns_unauth_when_not_logged_in,
        route_returns_unauth_when_using_valid_but_non_existant_user,
    },
    helpers::TestApp,
};

use super::story_relative_url_prefix;

impl TestApp {
    pub async fn post_story(&self, body: String) -> reqwest::Response {
        self.api_client
            .post(&format!("{}{}", &self.address, story_relative_url_prefix()))
            .header("Content-Type", "application/json")
            .body(body)
            .send()
            .await
            .expect("Failed to execute request.")
    }
}

#[tokio::test]
async fn post_story_returns_unauth_when_not_logged_in() {
    route_returns_unauth_when_not_logged_in(|_| story_relative_url_prefix(), Method::POST).await;
}

#[tokio::test]
async fn post_story_returns_unauth_when_logged_out() {
    let body = json!({"story": {"title": "Dune", "medium":"Book", "creator":"Frank Herbert" }});
    route_returns_unauth_when_logged_out(|_| story_relative_url_prefix(), Method::POST, body).await;
}

#[tokio::test]
async fn post_story_returns_unauth_when_using_valid_but_non_existant_user() {
    let body = json!({"story": {"title": "Dune", "medium":"Book", "creator":"Frank Herbert" }});
    route_returns_unauth_when_using_valid_but_non_existant_user(
        |_| story_relative_url_prefix(),
        Method::POST,
        body,
    )
    .await;
}

#[tokio::test]
async fn post_story_persists_the_new_story() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let body = json!({"story": {"title": "Dune", "medium":"Book", "creator":"Frank Herbert" }});
    let response = app.post_story(body.to_string()).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!(
        r#"
            SELECT 
                title, 
                (
                    SELECT name
                    FROM mediums
                    WHERE id = medium_id
                ) as medium,
                (
                    SELECT name
                    FROM creators
                    WHERE id = creator_id
                ) as creator
            FROM stories
            "#,
    )
    .fetch_one(&app.db_pool)
    .await
    .expect("Failed to fetch saved data.");

    assert_eq!(saved.medium, Some("Book".to_string()));
    assert_eq!(saved.creator, Some("Frank Herbert".to_string()));
    assert_eq!(saved.title, "Dune");
    app.teardown().await;
}

#[tokio::test]
async fn post_story_returns_a_400_when_data_is_missing() {
    // Arrange
    let app = TestApp::spawn_app().await;

    app.test_user.login(&app).await;
    let test_cases = vec![
        (
            json!({ "story": {"title": "Dune"} }),
            "missing the medium and creator",
        ),
        (
            json!({ "story": {"medium": "Book"} }),
            "missing the title and creator",
        ),
        (
            json!({"story":{"medium": "Book", "creator": "Frank Herbert"}}),
            "missing title",
        ),
    ];

    for (invalid_body, error_message) in test_cases {
        // Act
        let response = app.post_story(invalid_body.to_string()).await;

        // Assert
        assert_eq!(
            400,
            response.status().as_u16(),
            // Additional customised error message on test failure
            "The API did not fail with 400 Bad Request when the payload was {}.",
            error_message
        );
    }
    app.teardown().await;
}

#[tokio::test]
async fn post_story_returns_a_400_when_fields_are_present_but_invalid() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    let test_cases = vec![
        (
            json!({"story": {"title": "", "medium":"Book", "creator": "Frank Herbert" }}),
            "empty title",
        ),
        (
            json!({"story": {"title": "Dune", "medium":"", "creator": "Frank Herbert" }}),
            "empty medium",
        ),
        (
            json!({"story": {"title": "Dune", "medium":"Book", "creator": "" }}),
            "empty creator",
        ),
    ];
    for (body, description) in test_cases {
        // Act
        let response = app.post_story(body.to_string()).await;

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
async fn post_story_returns_json() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    let body = json!({"story": {"title": "Dune", "medium":"Film", "creator":"David Lynch" }});

    // Act
    let response = app.post_story(body.to_string()).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json: Value = response.json().await.expect("expected json response");
    assert_eq!(json["story"]["medium"], "Film");
    assert_eq!(json["story"]["creator"], "David Lynch");
    assert_eq!(json["story"]["title"], "Dune");
    app.teardown().await;
}
