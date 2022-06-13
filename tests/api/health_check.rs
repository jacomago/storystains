use crate::helpers::TestApp;

#[tokio::test]
async fn health_check_works() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let client = reqwest::Client::new();

    // Act
    let response = client
        // Use the returned application address
        .get(&format!("{}/health_check", &app.address))
        .send()
        .await
        .expect("Failed to execute request.");

    // Assert
    assert!(response.status().is_success());
    assert_eq!(Some(0), response.content_length());

    app.teardown().await;
}

#[tokio::test]
async fn db_check_works() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let client = reqwest::Client::new();

    // Act
    let response = client
        // Use the returned application address
        .get(&format!("{}/db_check", &app.address))
        .send()
        .await
        .expect("Failed to execute request.");

    // Assert
    assert!(response.status().is_success());
    assert_eq!(Some(0), response.content_length());

    app.teardown().await;
}

#[tokio::test]
async fn db_check_fails_if_emotion_data_doesnt_match() {
    // Arrange
    let app = TestApp::spawn_app().await;
    let client = reqwest::Client::new();

    // Act
    let _ =
        sqlx::query!("INSERT INTO emotions(id, name, description) values (22, 'French', 'fab')")
            .execute(&app.db_pool)
            .await
            .expect("Failed to fetch saved subscription.");
    let response = client
        // Use the returned application address
        .get(&format!("{}/db_check", &app.address))
        .send()
        .await
        .expect("Failed to execute request.");

    // Assert
    assert!(response.status().is_server_error());
    let text = &response.text().await.unwrap();
    assert_eq!(text, "Check on emotions failed.");

    app.teardown().await;
}
