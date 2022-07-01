use crate::api::shared::short_form_text::ShortFormText;

#[derive(serde::Deserialize, serde::Serialize)]
pub struct StoryResponse {
    pub story: StoryResponseData,
}

#[derive(serde::Deserialize, serde::Serialize)]
pub struct StoryResponseData {
    pub title: String,
    pub medium: String,
    pub creator: String,
}

#[derive(Debug)]
pub struct StoredStory {
    pub id: sqlx::types::Uuid,
    pub title: String,
    pub medium: Option<String>,
    pub creator: Option<String>,
}

impl From<StoredStory> for StoryResponseData {
    fn from(stored: StoredStory) -> Self {
        Self {
            title: stored.title,
            medium: stored.medium.unwrap_or_else(|| "Book".to_string()),
            creator: stored.creator.unwrap_or_else(|| "Anonymous".to_string()),
        }
    }
}
pub struct NewStory {
    pub title: ShortFormText,
    pub medium: ShortFormText,
    pub creator: ShortFormText,
}
