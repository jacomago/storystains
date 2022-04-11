use reqwest::Client;

use crate::domain::ReviewTitle;

#[derive(Clone)]
pub struct Catalog {
    http_client: Client,
    base_url: String
}

impl Catalog {
    pub fn new(base_url: String) -> Self {
        Self {
            http_client: Client::new(),
            base_url
        }
    }

    pub async fn get_book_url(
        &self,
        title: ReviewTitle
    ) -> Result<(), String> {
        todo!()
    }
}