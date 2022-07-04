use actix_web_lab::__reexports::futures_util::StreamExt;
use futures_lite::stream;
use reqwest::StatusCode;
use serde_json::Value;

use crate::{helpers::TestApp, story::test_story::TestStory};

use super::story_relative_url_prefix;

impl TestApp {
    pub async fn get_stories(&self, limit: Option<i64>) -> reqwest::Response {
        self.api_client
            .get(&format!("{}{}", &self.address, story_relative_url_prefix()))
            .query(&[("limit", limit)])
            .send()
            .await
            .expect("Failed to execute request.")
    }

    pub async fn get_stories_json(&self, limit: Option<i64>) -> String {
        self.get_stories(limit).await.text().await.unwrap()
    }
}

#[tokio::test]
async fn get_stories_returns_empty_list() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act
    let response = app.get_stories(Some(10)).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json_page = response.text().await.unwrap();
    let json: Value = serde_json::from_str(&json_page).unwrap();
    assert!(json["stories"].is_array());
    assert!(json["stories"].as_array().unwrap().is_empty());

    app.teardown().await;
}

#[tokio::test]
async fn get_stories_returns_allows_empty_query() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act
    let json_page = app.get_stories_json(None).await;

    // Assert
    let json: Value = serde_json::from_str(&json_page).unwrap();
    assert!(json["stories"].is_array());
    assert!(json["stories"].as_array().unwrap().is_empty());

    app.teardown().await;
}

#[tokio::test]
async fn get_stories_returns_bad_request_for_invalid_query() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act
    let response = app.get_stories(Some(-10)).await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);

    app.teardown().await;
}

#[tokio::test]
async fn get_stories_returns_stories() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;

    // Act
    let stories: Vec<TestStory> = (0..3).map(|_| TestStory::generate()).collect();
    stream::iter(&stories)
        .for_each(|s| s.store(&app, &token))
        .await;

    let response = app.get_stories(Some(10)).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json_page = response.text().await.unwrap();
    let json: Value = serde_json::from_str(&json_page).unwrap();
    assert!(json["stories"].is_array());
    assert_eq!(json["stories"].as_array().unwrap().len(), 3);

    // TODO might fail on order, better to sort both by something
    stories.iter().enumerate().for_each(|(i, s)| {
        assert_eq!(json["stories"][i]["title"], s.title);
        assert_eq!(json["stories"][i]["creator"], s.creator);
        assert_eq!(json["stories"][i]["medium"], s.medium);
    });

    app.teardown().await;
}