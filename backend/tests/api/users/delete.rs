use crate::{helpers::TestApp, users::TestUser};

impl TestApp {
    pub async fn delete_user(&self) -> reqwest::Response {
        self.api_client
            .delete(&format!("{}/users", &self.address))
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
    app.delete_user().await;

    // Act
    app.delete_user().await;

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
