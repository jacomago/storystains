use reqwest::StatusCode;
use serde_json::{json, Value};

use crate::helpers::{spawn_app, TestApp, TestUser};

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

    pub async fn get_review_json(&self, slug: String) -> String {
        self.get_review(slug).await.text().await.unwrap()
    }

    pub async fn get_reviews(&self, limit: Option<i64>, offset: Option<i64>) -> reqwest::Response {
        self.api_client
            .get(&format!("{}/reviews", &self.address))
            .query(&[("limit", limit), ("offset", offset)])
            .send()
            .await
            .expect("Failed to execute request.")
    }

    pub async fn get_reviews_json(&self, limit: Option<i64>, offset: Option<i64>) -> String {
        self.get_reviews(limit, offset).await.text().await.unwrap()
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
    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
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
    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
    let response = app.post_review(body.to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);
}

#[tokio::test]
async fn post_review_returns_unauth_when_using_valid_but_non_existant_user() {
    // Arrange
    let app = spawn_app().await;

    // create new user
    let user = TestUser::generate();
    // take token
    let token = user.store(&app).await;
    // delete user
    app.delete_user(&token).await;

    // Act
    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
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
    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
    let response = app.post_review(body.to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!("SELECT title, body FROM reviews",)
        .fetch_one(&app.db_pool)
        .await
        .expect("Failed to fetch saved subscription.");

    assert_eq!(saved.body, "5stars");
    assert_eq!(saved.title, "Dune");
}

#[tokio::test]
async fn post_review_returns_a_400_when_data_is_missing() {
    // Arrange
    let app = spawn_app().await;

    let token = app.test_user.login(&app).await;
    let test_cases = vec![
        (json!({"review": {"title": "Dune"} }), "missing the review"),
        (json!({ "review":{"body":"5stars"} }), "missing the title"),
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
            json!({"review": {"title": "", "body":"5stars" }}),
            "empty title",
        ),
        (
            json!({"review": {"title": "Dune", "body":"" }}),
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

    let body = json!({"review": {"title": "Dune", "body":"5stars" }});

    // Act
    let response = app.post_review(body.to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json: Value = response.json().await.expect("expected json response");
    assert_eq!(json["review"]["body"], "5stars");
    assert_eq!(json["review"]["title"], "Dune");
}

#[tokio::test]
async fn get_review_logged_in_returns_json() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    let body = json!({"review": {"title": "Dune", "body":"5stars" }});

    // Act
    let response = app.post_review(body.to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json_page = app.get_review_json("dune".to_string()).await;
    let json: Value = serde_json::from_str(&json_page).unwrap();
    assert_eq!(json["review"]["body"], "5stars");
    assert_eq!(json["review"]["title"], "Dune");
}

#[tokio::test]
async fn get_review_logged_out_returns_json() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    let body = json!({"review": {"title": "Dune", "body":"5stars" }});

    // Act
    let response = app.post_review(body.to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    app.test_user.logout().await;

    let json_page = app.get_review_json("dune".to_string()).await;
    let json: Value = serde_json::from_str(&json_page).unwrap();
    assert_eq!(json["review"]["body"], "5stars");
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
    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
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
    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
    app.post_review(body.to_string(), &token).await;
    let body = json!({"review": {"body":"3stars" }});
    let response = app
        .put_review("dune".to_string(), body.to_string(), &token)
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!("SELECT title, body FROM reviews",)
        .fetch_one(&app.db_pool)
        .await
        .expect("Failed to fetch saved subscription.");

    assert_eq!(saved.body, "3stars");
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
            json!({"review": {"title": "Dune", "body":"5stars" }}).to_string(),
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

    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
    app.post_review(body.to_string(), &token).await;

    let test_cases = vec![
        (
            json!({"review": {"title": "", "body":"5stars" }}),
            "empty title",
        ),
        (
            json!({"review": {"title": "Dune", "body":"" }}),
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

    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
    app.post_review(body.to_string(), &token).await;

    let body = json!({"review": {"title": "Dune2", "body":"3stars" }});

    // Act
    let response = app
        .put_review("dune".to_string(), body.to_string(), &token)
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);
    let json: Value = response.json().await.expect("expected json response");
    assert_eq!(json["review"]["body"], "3stars");
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
    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
    app.post_review(body.to_string(), &token).await;
    let response = app.delete_review("dune".to_string(), &token).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!("SELECT title, body FROM reviews",)
        .fetch_optional(&app.db_pool)
        .await
        .expect("Query failed to execute.");

    assert!(saved.is_none());
}

#[tokio::test]
async fn get_reviews_returns_empty_list() {
    // Arrange
    let app = spawn_app().await;

    // Act
    let response = app.get_reviews(Some(10), Some(0)).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json_page = response.text().await.unwrap();
    let json: Value = serde_json::from_str(&json_page).unwrap();
    assert!(json["reviews"].is_array());
    assert!(json["reviews"].as_array().unwrap().is_empty())
}

#[tokio::test]
async fn get_reviews_returns_allows_empty_query() {
    // Arrange
    let app = spawn_app().await;

    // Act
    let json_page = app.get_reviews_json(None, None).await;

    // Assert
    let json: Value = serde_json::from_str(&json_page).unwrap();
    assert!(json["reviews"].is_array());
    assert!(json["reviews"].as_array().unwrap().is_empty())
}

#[tokio::test]
async fn get_reviews_returns_bad_request_for_invalid_query() {
    // Arrange
    let app = spawn_app().await;

    // Act
    let response = app.get_reviews(Some(-10), Some(-10)).await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);
}

#[tokio::test]
async fn get_reviews_returns_reviews() {
    // Arrange
    let app = spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let body = json!({"review": {"title": "Dune", "body":"5stars" }});
    app.post_review(body.to_string(), &token).await;
    let body = json!({"review": {"title": "LoTR", "body":"4 stars" }});
    app.post_review(body.to_string(), &token).await;

    let response = app.get_reviews(Some(10), Some(0)).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json_page = response.text().await.unwrap();
    let json: Value = serde_json::from_str(&json_page).unwrap();
    assert!(json["reviews"].is_array());
    assert_eq!(json["reviews"].as_array().unwrap().len(), 2);

    assert_eq!(json["reviews"][0]["title"], "Dune");
    assert_eq!(json["reviews"][0]["body"], "5stars");

    assert_eq!(json["reviews"][1]["title"], "LoTR");
    assert_eq!(json["reviews"][1]["body"], "4 stars");
}
