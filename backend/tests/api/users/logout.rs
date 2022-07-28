use crate::helpers::TestApp;

impl TestApp {
    pub async fn post_logout(&self) -> reqwest::Response {
        self.api_client
            .post(&format!("{}/users/logout", &self.address))
            .send()
            .await
            .expect("Failed to execute request.")
    }
}
