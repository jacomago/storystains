#[derive(serde::Deserialize, serde::Serialize)]
pub struct StoryResponseData {
    pub title: String,
    pub medium: String,
    pub creator: String,
}
