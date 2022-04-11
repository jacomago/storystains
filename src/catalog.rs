use reqwest::Client;

pub struct Catalog {
    http_client: Client,
    base_url: String
}

impl Catalog {
    pub async fn get_book_url(
        &self,
        title: ReviewTitle
    ) -> Result<(), String> {
        todo!()
    }
}