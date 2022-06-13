use core::time;
use std::thread;

use serde_json::Value;
use uuid::Uuid;

use super::TestApp;
pub struct TestUser {
    pub user_id: Uuid,
    pub username: String,
    pub password: String,
    pub exp_seconds: u64,
}

impl TestUser {
    pub fn generate() -> Self {
        Self {
            user_id: Uuid::new_v4(),
            username: Uuid::new_v4().to_string(),
            password: Uuid::new_v4().to_string(),
            exp_seconds: 1,
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

    pub async fn login(&self, app: &TestApp) -> String {
        let response = app
            .post_login(
                serde_json::json!({
                    "user": {
                        "username": &self.username,
                        "password": &self.password
                    }
                })
                .to_string(),
            )
            .await;

        let json: Value = response.json().await.expect("expected json response");
        json["user"]["token"].as_str().unwrap().to_string()
    }

    pub async fn logout(&self) {
        thread::sleep(time::Duration::from_secs(self.exp_seconds + 2));
    }

    pub async fn store(&self, app: &TestApp) -> String {
        let signup_body = serde_json::json!({
            "user": {
                "username": &self.username,
                "password": &self.password
            }
        });
        let response = app.post_signup(signup_body.to_string()).await;

        let json: Value = response.json().await.expect("expected json response");
        json["user"]["token"].as_str().unwrap().to_string()
    }
}
