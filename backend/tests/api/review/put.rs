use reqwest::{Method, StatusCode};
use serde_json::{json, Value};

use crate::{
    auth::route_returns_unauth_when_not_logged_in, helpers::TestApp,
    review::test_review::TestReview, story::TestStory, users::TestUser,
};

use super::review_relative_url;

impl TestApp {
    pub async fn put_review(&self, username: &str, slug: &str, body: String) -> reqwest::Response {
        self.api_client
            .put(&format!(
                "{}{}",
                &self.address,
                review_relative_url(username, slug)
            ))
            .header("Content-Type", "application/json")
            .body(body)
            .send()
            .await
            .expect("Failed to execute request.")
    }
}

#[tokio::test]
async fn put_review_returns_unauth_when_not_logged_in() {
    route_returns_unauth_when_not_logged_in(
        |username| review_relative_url(username, "slug"),
        Method::PUT,
    )
    .await;
}

#[tokio::test]
async fn put_review_returns_a_200_for_valid_json_data() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let review = TestReview::generate(&app.test_user);
    review.store(&app).await;
    let story = TestStory::generate();
    let body = json!({"review": {"story": story.create_inner_json(), "body":"3stars" }});
    let response = app
        .put_review(&app.test_user.username, review.slug(), body.to_string())
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!(
        "SELECT (select title from stories where id = story_id) as title, body FROM reviews",
    )
    .fetch_one(&app.db_pool)
    .await
    .expect("Failed to fetch saved data.");

    assert_eq!(saved.body, Some("3stars".to_string()));
    assert_eq!(saved.title, Some(story.title));
    app.teardown().await;
}

#[tokio::test]
async fn put_review_returns_not_found_for_non_existant_review() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let response = app
        .put_review(
            &app.test_user.username,
            "dune",
            json!({"review": {"body":"5stars" }}).to_string(),
        )
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::NOT_FOUND);
    app.teardown().await;
}

#[tokio::test]
async fn put_review_returns_bad_request_for_invalid_slug() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    // Act
    let response = app
        .put_review(&app.test_user.username, &"a".repeat(257), "".to_string())
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::BAD_REQUEST);
    app.teardown().await;
}

#[tokio::test]
async fn put_review_returns_a_400_when_fields_are_present_but_invalid() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    let review = TestReview::generate(&app.test_user);
    review.store(&app).await;

    let story = TestStory::generate();
    let test_cases = vec![
        (
            json!({"review": { "story": story.create_inner_json(), "body":"" }}),
            "empty review",
        ),
        (
            json!({"review": { "story":{}, "body": "body"}}),
            "empty story",
        ),
    ];
    for (body, description) in test_cases {
        // Act
        let response = app
            .put_review(&app.test_user.username, review.slug(), body.to_string())
            .await;

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
async fn put_review_returns_json() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    let review = TestReview::generate(&app.test_user);
    review.store(&app).await;
    let story = TestStory::generate();

    let body = json!({"review": { "story": story.create_inner_json(), "body":"3stars" }});

    // Act
    let response = app
        .put_review(&app.test_user.username, review.slug(), body.to_string())
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);
    let json: Value = response.json().await.expect("expected json response");
    assert_eq!(json["review"]["body"], "3stars");
    assert_eq!(json["review"]["story"]["title"], story.title);
    app.teardown().await;
}

#[tokio::test]
async fn put_review_only_allows_creator_to_modify() {
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.login(&app).await;

    let review = TestReview::generate(&app.test_user);
    review.store(&app).await;

    let body = json!({"review": {"body":"3stars" }});

    let new_user = TestUser::generate();
    new_user.store(&app).await;
    new_user.set_admin(&app).await;

    // Act
    let response = app
        .put_review(&app.test_user.username, review.slug(), body.to_string())
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::FORBIDDEN);
    app.teardown().await;
}
