use reqwest::Client;

use crate::domain::ReviewTitle;

#[derive(Clone)]
pub struct CatalogClient {
    http_client: Client,
    base_url: String,
}

impl CatalogClient {
    pub fn new(base_url: String) -> Self {
        Self {
            http_client: Client::new(),
            base_url,
        }
    }

    pub async fn get_book_url(&self, title: ReviewTitle) -> Result<(), String> {
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use wiremock::matchers::any;
    use wiremock::{Mock, MockServer, ResponseTemplate};

    use crate::domain::ReviewTitle;

    use super::CatalogClient;

    #[tokio::test]
    async fn get_book_url_fires_a_request_to_base_url() {
        // Arrange
        let mock_server = MockServer::start().await;
        let catalog_client = CatalogClient::new(mock_server.uri());

        Mock::given(any())
            .respond_with(ResponseTemplate::new(200))
            .expect(1)
            .mount(&mock_server)
            .await;

        let review_title = ReviewTitle::parse(format!("Lord of the Rings")).unwrap();

        //Act
        let _ = catalog_client.get_book_url(review_title).await;

        //Assert
    }
}
