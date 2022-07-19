use reqwest::StatusCode;
use serde_json::{json, Value};

use crate::{
    helpers::{TestApp, TestQuery},
    story::TestStory,
    users::TestUser,
};

use super::review_relative_url_prefix;

impl TestApp {
    pub async fn get_reviews(&self, query: &TestQuery) -> reqwest::Response {
        self.api_client
            .get(&format!(
                "{}{}",
                &self.address,
                review_relative_url_prefix()
            ))
            .query(query)
            .send()
            .await
            .expect("Failed to execute request.")
    }

    pub async fn get_reviews_json(&self, query: &TestQuery) -> String {
        self.get_reviews(query).await.text().await.unwrap()
    }
}

#[tokio::test]
async fn get_reviews_returns_empty_list() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act
    let response = app.get_reviews(TestQuery::new().limit(10).offset(0)).await;

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
    let json_page = app.get_reviews_json(&TestQuery::new()).await;

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
    let response = app
        .get_reviews(TestQuery::new().limit(-10).offset(-10))
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);

    app.teardown().await;
}

#[tokio::test]
async fn get_reviews_returns_reviews() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let first_story = TestStory::generate();
    let body = json!({"review": {"story": first_story.create_inner_json(), "body":"5stars" }});
    app.post_review(body.to_string()).await;
    let second_story = TestStory::generate();
    let body = json!({"review": {"story": second_story.create_inner_json(), "body":"4 stars" }});
    app.post_review(body.to_string()).await;

    let response = app.get_reviews(TestQuery::new().limit(10).offset(0)).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json_page = response.text().await.unwrap();
    let json: Value = serde_json::from_str(&json_page).unwrap();
    assert!(json["reviews"].is_array());
    assert_eq!(json["reviews"].as_array().unwrap().len(), 2);

    assert_eq!(json["reviews"][0]["story"]["title"], second_story.title);
    assert_eq!(json["reviews"][0]["body"], "4 stars");

    assert_eq!(json["reviews"][1]["story"]["title"], first_story.title);
    assert_eq!(json["reviews"][1]["body"], "5stars");

    app.teardown().await;
}

#[tokio::test]
#[ignore = "often fails in code coverage ci"]
async fn get_reviews_returns_reviews_singular_multi_user() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let other_user = TestUser::generate();
    other_user.store(&app).await;

    let first_story = TestStory::generate();
    let body = json!({"review": {"story": first_story.create_inner_json(), "body":"5stars" }});
    app.post_review(body.to_string()).await;
    let second_story = TestStory::generate();
    let body = json!({"review": {"story": second_story.create_inner_json(), "body":"4 stars" }});
    app.post_review(body.to_string()).await;

    let response = app.get_reviews(TestQuery::new().limit(10).offset(0)).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json_page = response.text().await.unwrap();
    let json: Value = serde_json::from_str(&json_page).unwrap();
    assert!(json["reviews"].is_array());
    assert_eq!(json["reviews"].as_array().unwrap().len(), 2);

    assert_eq!(json["reviews"][0]["story"]["title"], second_story.title);
    assert_eq!(json["reviews"][0]["body"], "4 stars");

    assert_eq!(json["reviews"][1]["story"]["title"], first_story.title);
    assert_eq!(json["reviews"][1]["body"], "5stars");

    app.teardown().await;
}

#[tokio::test]
async fn get_reviews_filtered_user() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let first_story = TestStory::generate();
    let body = json!({"review": {"story": first_story.create_inner_json(), "body":"5stars" }});
    app.post_review(body.to_string()).await;

    let other_user = TestUser::generate();
    other_user.store(&app).await;
    let second_story = TestStory::generate();
    let body = json!({"review": {"story": second_story.create_inner_json(), "body":"4 stars" }});
    app.post_review(body.to_string()).await;

    let response = app
        .get_reviews(
            TestQuery::new()
                .limit(10)
                .offset(0)
                .username(other_user.username),
        )
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json_page = response.text().await.unwrap();
    let json: Value = serde_json::from_str(&json_page).unwrap();
    assert!(json["reviews"].is_array());
    assert_eq!(json["reviews"].as_array().unwrap().len(), 1);

    assert_eq!(json["reviews"][0]["story"]["title"], second_story.title);
    assert_eq!(json["reviews"][0]["body"], "4 stars");

    app.teardown().await;
}

#[tokio::test]
async fn get_reviews_filtered_story() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let first_story = TestStory::generate();
    let body = json!({"review": {"story": first_story.create_inner_json(), "body":"5stars" }});
    app.post_review(body.to_string()).await;
    let second_story = TestStory::generate().medium("Film".to_string()).clone();
    let body = json!({"review": {"story": second_story.create_inner_json(), "body":"4 stars" }});
    app.post_review(body.to_string()).await;

    let queries = [
        TestQuery::new()
            .limit(10)
            .offset(0)
            .creator(second_story.creator.clone())
            .clone(),
        TestQuery::new()
            .limit(10)
            .offset(0)
            .title(second_story.title.clone())
            .clone(),
        TestQuery::new()
            .limit(10)
            .offset(0)
            .medium(second_story.medium.clone())
            .clone(),
    ];
    for q in queries {
        let response = app.get_reviews(&q).await;

        // Assert
        assert_eq!(response.status(), StatusCode::OK);

        let json_page = response.text().await.unwrap();
        let json: Value = serde_json::from_str(&json_page).unwrap();
        assert!(json["reviews"].is_array());
        assert_eq!(json["reviews"].as_array().unwrap().len(), 1);

        assert_eq!(json["reviews"][0]["story"]["title"], second_story.title);
        assert_eq!(json["reviews"][0]["body"], "4 stars");
    }
    app.teardown().await;
}
