use reqwest::StatusCode;
use serde_json::{json, Value};

use crate::helpers::{spawn_app, TestApp};


impl TestApp {

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
