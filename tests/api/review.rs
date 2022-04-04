use crate::helpers::spawn_app;

#[tokio::test]
async fn review_returns_a_200_for_valid_form_data() {
    // Arrange
    let app = spawn_app().await;

    // Act
    let body = "title=Dune&review=5stars";
    let response = app.post_review(body.into()).await;

    // Assert
    assert_eq!(200, response.status().as_u16());
}

#[tokio::test]
async fn review_returns_a_400_when_data_is_missing() {
    // Arrange
    let app = spawn_app().await;
    let test_cases = vec![
        ("title=Dune", "missing the review"),
        ("review=5stars", "missing the title"),
        ("", "missing both title and review"),
    ];

    for (invalid_body, error_message) in test_cases {
        // Act
        let response = app.post_review(invalid_body.into()).await;

        // Assert
        assert_eq!(
            400,
            response.status().as_u16(),
            // Additional customised error message on test failure
            "The API did not fail with 400 Bad Request when the payload was {}.",
            error_message
        );
    }
}
