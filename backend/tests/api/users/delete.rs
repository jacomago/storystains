use reqwest::StatusCode;

use crate::{helpers::TestApp, users::TestUser};

impl TestApp {
    pub async fn delete_logged_in_user(&self) -> reqwest::Response {
        self.api_client
            .delete(&format!("{}/users", &self.address))
            .header("Content-Type", "application/json")
            .send()
            .await
            .expect("Failed to execute request.")
    }
    pub async fn delete_user(&self, username: &str) -> reqwest::Response {
        self.api_client
            .delete(&format!("{}/users/{}", &self.address, username))
            .header("Content-Type", "application/json")
            .send()
            .await
            .expect("Failed to execute request.")
    }
}

#[tokio::test]
async fn delete_user_deletes_user() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // create new user
    let user = TestUser::generate();
    // store user
    user.store(&app).await;
    // delete user
    app.delete_logged_in_user().await;

    // Act
    app.delete_logged_in_user().await;

    let saved = sqlx::query!(
        "SELECT user_id FROM users WHERE username = $1",
        user.username
    )
    .fetch_optional(&app.db_pool)
    .await
    .expect("Failed to fetch saved data.");

    // Assert
    assert!(saved.is_none());

    app.teardown().await;
}

#[tokio::test]
async fn block_delete_by_other_user() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // create new user
    let user = TestUser::generate();
    // store user
    user.store(&app).await;

    // Act
    // delete user
    let response = app.delete_user(&app.test_user.username).await;

    // Assert
    assert_eq!(response.status(), StatusCode::FORBIDDEN);

    app.teardown().await;
}

#[tokio::test]
async fn allow_delete_by_admin() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // create new user
    let user = TestUser::generate();
    // store user
    user.store(&app).await;
    user.set_admin(&app).await;

    // Act
    // delete user
    let response = app.delete_user(&app.test_user.username).await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let saved = sqlx::query!(
        "SELECT user_id FROM users WHERE username = $1",
        user.username
    )
    .fetch_all(&app.db_pool)
    .await
    .expect("Failed to fetch saved data.");

    // Assert
    assert_eq!(saved.len(), 1);

    app.teardown().await;
}
