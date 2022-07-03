use reqwest::StatusCode;
use serde_json::Value;

use crate::helpers::TestApp;

impl TestApp {
    pub async fn get_mediums(&self) -> reqwest::Response {
        self.api_client
            .get(&format!("{}/mediums", &self.address))
            .send()
            .await
            .expect("Failed to execute request.")
    }
}

#[tokio::test]
async fn get_mediums_returns_list() {
    // Arrange
    let app = TestApp::spawn_app().await;

    // Act
    let response = app.get_mediums().await;

    // Assert
    assert_eq!(response.status(), StatusCode::OK);

    let json_page = response.text().await.unwrap();
    let json: Value = serde_json::from_str(&json_page).unwrap();

    assert!(json["mediums"].is_array());

    let mediums = json["mediums"].as_array().unwrap();
    assert_eq!(mediums.len(), 12);
    assert!(mediums.iter().any(|x| x["name"] == "Book"));
    assert!(mediums.iter().any(|x| x["name"] == "Film"));
    assert!(mediums.iter().any(|x| x["name"] == "Short Story"));
    app.teardown().await;
}
