use actix_web_lab::__reexports::futures_util::StreamExt;
use futures_lite::stream;
use reqwest::StatusCode;
use serde_json::Value;

use crate::{
    helpers::{TestApp, TestQuery},
    story::test_story::TestStory,
};

use super::story_relative_url_prefix;

impl TestApp {
    pub async fn get_stories(&self, query: &TestQuery) -> reqwest::Response {
        self.api_client
            .get(&format!("{}{}", &self.address, story_relative_url_prefix()))
            .query(&query)
            .send()
            .await
            .expect("Failed to execute request.")
    }

    pub async fn get_stories_json(&self, query: &TestQuery) -> String {
        self.get_stories(query).await.text().await.unwrap()
    }
}

#[tokio::test]
async fn get_stories_returns_empty_list() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act
    let response = app.get_stories(TestQuery::new().limit(10)).await;

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
    let json_page = app.get_stories_json(&TestQuery::new()).await;

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
    let response = app.get_stories(TestQuery::new().limit(-10)).await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);

    app.teardown().await;
}

#[tokio::test]
async fn get_stories_returns_stories() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let stories: Vec<TestStory> = (0..3).map(|_| TestStory::generate()).collect();
    stream::iter(&stories).for_each(|s| s.store(&app)).await;

    let response = app.get_stories(TestQuery::new().limit(10)).await;

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

#[tokio::test]
async fn get_stories_obeys_limit() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let stories: Vec<TestStory> = (0..3).map(|_| TestStory::generate()).collect();
    stream::iter(&stories).for_each(|s| s.store(&app)).await;

    let response = app.get_stories(TestQuery::new().limit(1)).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json_page = response.text().await.unwrap();
    let json: Value = serde_json::from_str(&json_page).unwrap();
    assert!(json["stories"].is_array());
    assert_eq!(json["stories"].as_array().unwrap().len(), 1);

    // TODO might fail on order, better to sort both by something
    assert_eq!(json["stories"][0]["title"], stories[0].title);
    assert_eq!(json["stories"][0]["creator"], stories[0].creator);
    assert_eq!(json["stories"][0]["medium"], stories[0].medium);

    app.teardown().await;
}

#[tokio::test]
async fn get_stories_by_query_not_found() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let stories: Vec<TestStory> = (0..3).map(|_| TestStory::generate()).collect();
    stream::iter(&stories).for_each(|s| s.store(&app)).await;

    // Test story only generates english words, so can use french to not get a hit
    let queries = [
        TestQuery::new()
            .limit(10)
            .title("Parlez".to_string())
            .clone(),
        TestQuery::new()
            .limit(10)
            .medium("Film".to_string())
            .clone(),
        TestQuery::new()
            .limit(10)
            .creator("Parlez".to_string())
            .clone(),
    ];

    for q in queries {
        let response = app.get_stories(&q).await;
        // Assert
        assert_eq!(response.status(), StatusCode::OK);

        let json_page = response.text().await.unwrap();
        let json: Value = serde_json::from_str(&json_page).unwrap();
        assert!(json["stories"].is_array());
        assert_eq!(json["stories"].as_array().unwrap().len(), 0);
    }

    app.teardown().await;
}

#[tokio::test]
async fn get_stories_by_query_found() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let stories: Vec<TestStory> = vec![
        TestStory {
            title: "Metabarons".to_string(),
            medium: "Comic Book".to_string(),
            creator: "Jorowdowsky".to_string(),
        },
        TestStory {
            title: "Dune".to_string(),
            medium: "Book".to_string(),
            creator: "Frank Herbert".to_string(),
        },
        TestStory {
            title: "Star Wars: Episode 3".to_string(),
            medium: "Film".to_string(),
            creator: "George Lucas".to_string(),
        },
    ];

    stream::iter(&stories).for_each(|s| s.store(&app)).await;

    // Test story only generates english words, so can use french to not get a hit
    let queries = vec![
        TestQuery::new().limit(10).title("Meta".to_string()).clone(),
        TestQuery::new()
            .limit(10)
            .medium("Book".to_string())
            .clone(),
        // Default similarity in postgres is 30%, so 'Geor' would not match
        TestQuery::new()
            .limit(10)
            .creator("Georg".to_string())
            .clone(),
    ];

    for (i, q) in queries.iter().enumerate() {
        let response = app.get_stories(q).await;

        // Assert
        assert_eq!(response.status(), StatusCode::OK);

        let json_page = response.text().await.unwrap();
        let json: Value = serde_json::from_str(&json_page).unwrap();
        assert!(json["stories"].is_array());
        assert_eq!(json["stories"].as_array().unwrap().len(), 1);

        assert_eq!(json["stories"][0]["title"], stories[i].title);
        assert_eq!(json["stories"][0]["creator"], stories[i].creator);
        assert_eq!(json["stories"][0]["medium"], stories[i].medium);
    }

    app.teardown().await;
}
