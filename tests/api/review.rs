use reqwest::StatusCode;
use serde_json::{json, Value};

use crate::helpers::{spawn_app, TestApp};

impl TestApp {
    pub async fn post_review(&self, body: String, token: &str) -> reqwest::Response {
        self.api_client
            .post(&format!("{}/reviews", &self.address))
            .header("Content-Type", "application/json")
            .bearer_auth(token)
            .body(body)
            .send()
            .await
            .expect("Failed to execute request.")
    }

    pub async fn put_review(&self, slug: String, body: String, token: &str) -> reqwest::Response {
        self.api_client
            .put(&format!("{}/reviews/{}", &self.address, &slug))
            .header("Content-Type", "application/json")
            .bearer_auth(token)
            .body(body)
            .send()
            .await
            .expect("Failed to execute request.")
    }

    pub async fn get_review(&self, slug: String) -> reqwest::Response {
        self.api_client
            .get(&format!("{}/reviews/{}", &self.address, &slug))
            .send()
            .await
            .expect("Failed to execute request.")
    }

    pub async fn get_review_json(&self, title: String) -> String {
        self.get_review(title).await.text().await.unwrap()
    }

    pub async fn delete_review(&self, slug: String, token: &str) -> reqwest::Response {
        self.api_client
            .delete(&format!("{}/reviews/{}", &self.address, &slug))
            .bearer_auth(token)
            .send()
            .await
            .expect("Failed to execute request.")
    }
}

#[tokio::test]
async fn post_review_returns_unauth_when_not_logged_in() {
    // Arrange
    let app = spawn_app().await;

    // Act
    let body = json!({"review": {"title": "Dune", "review":"5stars" }});
    let response = app.post_review(body.to_string(), "").await;

    // Assert
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);
}

#[tokio::test]
async fn post_review_returns_unauth_when_logged_out() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;
    app.test_user.logout().await;

    // Act
    let body = json!({"review": {"title": "Dune", "review":"5stars" }});
    let response = app.post_review(body.to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);
}

#[tokio::test]
async fn post_review_persists_the_new_review() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let body = json!({"review": {"title": "Dune", "review":"5stars" }});
    let response = app.post_review(body.to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

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

    let token = app.test_user.login(&app).await;
    let test_cases = vec![
        (json!({"review": {"title": "Dune"} }), "missing the review"),
        (json!({ "review":{"review":"5stars"} }), "missing the title"),
        (json!({"review":{}}), "missing both title and review"),
    ];

    for (invalid_body, error_message) in test_cases {
        // Act
        let response = app.post_review(invalid_body.to_string(), &token).await;

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
    let token = app.test_user.login(&app).await;

    let test_cases = vec![
        (
            json!({"review": {"title": "", "review":"5stars" }}),
            "empty title",
        ),
        (
            json!({"review": {"title": "Dune", "review":"" }}),
            "empty review",
        ),
    ];
    for (body, description) in test_cases {
        // Act
        let response = app.post_review(body.to_string(), &token).await;

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
async fn post_review_returns_json() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    let body = json!({"review": {"title": "Dune", "review":"5stars" }});

    // Act
    let response = app.post_review(body.to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json: Value = response.json().await.expect("expected json response");
    assert_eq!(json["review"]["review"], "5stars");
    assert_eq!(json["review"]["title"], "Dune");
}

#[tokio::test]
async fn get_review_logged_in_returns_json() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    let body = json!({"review": {"title": "Dune", "review":"5stars" }});

    // Act
    let response = app.post_review(body.to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json_page = app.get_review_json("dune".to_string()).await;
    let json: Value = serde_json::from_str(&json_page).unwrap();
    assert_eq!(json["review"]["review"], "5stars");
    assert_eq!(json["review"]["title"], "Dune");
}

#[tokio::test]
async fn get_review_logged_out_returns_json() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    let body = json!({"review": {"title": "Dune", "review":"5stars" }});

    // Act
    let response = app.post_review(body.to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    app.test_user.logout().await;

    let json_page = app.get_review_json("dune".to_string()).await;
    let json: Value = serde_json::from_str(&json_page).unwrap();
    assert_eq!(json["review"]["review"], "5stars");
    assert_eq!(json["review"]["title"], "Dune");
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
async fn put_review_returns_unauth_when_not_logged_in() {
    // Arrange
    let app = spawn_app().await;

    // Act
    let body = json!({"review": {"title": "Dune", "review":"5stars" }});
    let response = app
        .put_review("dune".to_string(), body.to_string(), "")
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);
}

#[tokio::test]
async fn put_review_returns_a_200_for_valid_json_data() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let body = json!({"review": {"title": "Dune", "review":"5stars" }});
    app.post_review(body.to_string(), &token).await;
    let body = json!({"review": {"review":"3stars" }});
    let response = app
        .put_review("dune".to_string(), body.to_string(), &token)
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

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
    let token = app.test_user.login(&app).await;

    // Act
    let response = app
        .put_review(
            "dune".to_string(),
            json!({"review": {"title": "Dune", "review":"5stars" }}).to_string(),
            &token,
        )
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::NOT_FOUND);
}

#[tokio::test]
async fn put_review_returns_bad_request_for_invalid_slug() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let response = app
        .put_review("a".repeat(257).to_string(), "".to_string(), &token)
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);
}

#[tokio::test]
async fn put_review_returns_a_400_when_fields_are_present_but_invalid() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    let body = json!({"review": {"title": "Dune", "review":"5stars" }});
    app.post_review(body.to_string(), &token).await;

    let test_cases = vec![
        (
            json!({"review": {"title": "", "review":"5stars" }}),
            "empty title",
        ),
        (
            json!({"review": {"title": "Dune", "review":"" }}),
            "empty review",
        ),
    ];
    for (body, description) in test_cases {
        // Act
        let response = app
            .put_review("dune".to_string(), body.to_string(), &token)
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
async fn put_review_returns_json() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    let body = json!({"review": {"title": "Dune", "review":"5stars" }});
    app.post_review(body.to_string(), &token).await;

    let body = json!({"review": {"title": "Dune2", "review":"3stars" }});

    // Act
    let response = app
        .put_review("dune".to_string(), body.to_string(), &token)
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);
    let json: Value = response.json().await.expect("expected json response");
    assert_eq!(json["review"]["review"], "3stars");
    assert_eq!(json["review"]["title"], "Dune2");
}

#[tokio::test]
async fn delete_review_returns_unauth_when_not_logged_in() {
    // Arrange
    let app = spawn_app().await;

    // Act
    let response = app.delete_review("dune".to_string(), "").await;

    // Assert
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);
}

#[tokio::test]
async fn delete_review_returns_bad_request_for_invalid_title() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let response = app.delete_review("a".repeat(257).to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);
}

#[tokio::test]
async fn delete_review_returns_a_200_for_valid_slug() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let body = json!({"review": {"title": "Dune", "review":"5stars" }});
    app.post_review(body.to_string(), &token).await;
    let response = app.delete_review("dune".to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!("SELECT title, review FROM reviews",)
        .fetch_optional(&app.db_pool)
        .await
        .expect("Query failed to execute.");

    assert!(saved.is_none());
}
