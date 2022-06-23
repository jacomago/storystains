use reqwest::{Method, Response, StatusCode};

use crate::helpers::TestApp;

impl TestApp {
    pub async fn method_route(
        &self,
        route: &str,
        method: Method,
        body: String,
        token: &str,
    ) -> Response {
        self.api_client
            .request(method, &format!("{}{}", self.address, route))
            .header("Content-Type", "application/json")
            .bearer_auth(token)
            .body(body)
            .send()
            .await
            .expect("Failed to execute request.")
    }
}

pub async fn route_returns_unauth_when_not_logged_in(route: &str, method: Method) {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act
    let response = app.method_route(route, method, "".to_string(), "").await;

    // Assert
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);

    app.teardown().await;
}

pub async fn route_returns_unauth_when_logged_out(
    route: &str,
    method: Method,
    body: serde_json::Value,
) {
    // Arrange
    let app = TestApp::spawn_app().await;
    let token = app.test_user.login(&app).await;
    app.test_user.logout().await;

    // Act
    let response = app
        .method_route(route, method, body.to_string(), &token)
        .await;

    // Assert
    assert_eq!(response.status(), StatusCode::UNAUTHORIZED);
    app.teardown().await;
}
