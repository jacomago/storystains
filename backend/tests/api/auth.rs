use reqwest::{Method, Response, StatusCode};

use crate::{helpers::TestApp, users::TestUser};

impl TestApp {
    pub async fn method_route(&self, route: String, method: Method, body: String) -> Response {
        self.api_client
            .request(method, &format!("{}{}", self.address, route))
            .header("Content-Type", "application/json")
            .body(body)
            .send()
            .await
            .expect("Failed to execute request.")
    }
}

pub async fn route_returns_unauth_when_not_logged_in<T>(route: T, method: Method)
where
    T: Fn(&str) -> String,
{
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.logout(&app).await;

    // Act
    let response = app
        .method_route(route(&app.test_user.username), method, "".to_string())
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);

    app.teardown().await;
}

pub async fn route_returns_unauth_when_logged_out<T>(
    route: T,
    method: Method,
    body: serde_json::Value,
) where
    T: Fn(&str) -> String,
{
    // Arrange
    let app = TestApp::spawn_app().await;
    app.test_user.logout(&app).await;

    // Act
    let response = app
        .method_route(route(&app.test_user.username), method, body.to_string())
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);
    app.teardown().await;
}

pub async fn route_returns_unauth_when_using_valid_but_non_existant_user<T>(
    route: T,
    method: Method,
    body: serde_json::Value,
) where
    T: Fn(&str) -> String,
{
    // Arrange
    let app = TestApp::spawn_app().await;

    // create new user
    let user = TestUser::generate();
    // store user
    user.store(&app).await;
    // delete user
    app.delete_logged_in_user().await;

    // Act
    let response = app
        .method_route(route(&app.test_user.username), method, body.to_string())
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);
    app.teardown().await;
}
