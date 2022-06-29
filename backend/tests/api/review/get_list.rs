use reqwest::StatusCode;
use serde_json::{json, Value};

use crate::helpers::{TestApp, TestUser};

use super::review_relative_url_prefix;

impl TestApp {
    pub async fn get_reviews(&self, limit: Option<i64>, offset: Option<i64>) -> reqwest::Response {
        self.api_client
            .get(&format!(
                "{}{}",
                &self.address,
                review_relative_url_prefix()
            ))
            .query(&[("limit", limit), ("offset", offset)])
            .send()
            .await
            .expect("Failed to execute request.")
    }

    pub async fn get_reviews_json(&self, limit: Option<i64>, offset: Option<i64>) -> String {
        self.get_reviews(limit, offset).await.text().await.unwrap()
    }
}

#[tokio::test]
async fn get_reviews_returns_empty_list() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act
    let response = app.get_reviews(Some(10), Some(0)).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json_page = response.text().await.unwrap();
    let json: Value = serde_json::from_str(&json_page).unwrap();
    assert!(json["reviews"].is_array());
    assert!(json["reviews"].as_array().unwrap().is_empty());

    app.teardown().await;
}

#[tokio::test]
async fn get_reviews_returns_allows_empty_query() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act
    let json_page = app.get_reviews_json(None, None).await;

    // Assert
    let json: Value = serde_json::from_str(&json_page).unwrap();
    assert!(json["reviews"].is_array());
    assert!(json["reviews"].as_array().unwrap().is_empty());

    app.teardown().await;
}

#[tokio::test]
async fn get_reviews_returns_bad_request_for_invalid_query() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act
    let response = app.get_reviews(Some(-10), Some(-10)).await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);

    app.teardown().await;
}

#[tokio::test]
async fn get_reviews_returns_reviews() {
    // Arrange
    let app = TestApp::spawn_app().await;
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

    assert_eq!(json["reviews"][0]["title"], "LoTR");
    assert_eq!(json["reviews"][0]["body"], "4 stars");

    assert_eq!(json["reviews"][1]["title"], "Dune");
    assert_eq!(json["reviews"][1]["body"], "5stars");

    app.teardown().await;
}

#[tokio::test]
async fn get_reviews_returns_reviews_singular_multi_user() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let other_user = TestUser::generate();
    other_user.store(&app).await;

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

    assert_eq!(json["reviews"][0]["title"], "LoTR");
    assert_eq!(json["reviews"][0]["body"], "4 stars");
    assert_eq!(json["reviews"][1]["title"], "Dune");
    assert_eq!(json["reviews"][1]["body"], "5stars");

    app.teardown().await;
}
