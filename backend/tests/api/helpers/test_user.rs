use uuid::Uuid;

use super::TestApp;
pub struct TestUser {
    pub user_id: Uuid,
    pub username: String,
    pub password: String,
}

impl TestUser {
    pub fn generate() -> Self {
        Self {
            user_id: Uuid::new_v4(),
            username: Uuid::new_v4().to_string(),
            password: Uuid::new_v4().to_string(),
        }
    }

    pub fn to_json(&self) -> String {
        serde_json::json!({
            "user": {
                "username": &self.username,
                "password": &self.password
            }
        })
        .to_string()
    }

    pub async fn login(&self, app: &TestApp) {
        app.post_login(
            serde_json::json!({
                "user": {
                    "username": &self.username,
                    "password": &self.password
                }
            })
            .to_string(),
        )
        .await;
    }

    pub async fn logout(&self, app: &TestApp) {
        app.post_logout().await;
    }

    pub async fn store(&self, app: &TestApp) {
        let signup_body = serde_json::json!({
            "user": {
                "username": &self.username,
                "password": &self.password
            }
        });
        app.post_signup(signup_body.to_string()).await;
    }
}
