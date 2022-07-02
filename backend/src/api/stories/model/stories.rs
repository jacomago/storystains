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

impl TryFrom<StoryResponseData> for NewStory {
    type Error = String;
    fn try_from(value: StoryResponseData) -> Result<Self, Self::Error> {
        let title = ShortFormText::parse(value.title)?;
        let medium = ShortFormText::parse(value.medium)?;
        let creator = ShortFormText::parse(value.creator)?;
        Ok(Self {
            title,
            medium,
            creator,
        })
    }
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

impl NewStory {
    pub fn slugify(&self) -> String {
        self.title.slugify()
    }
}

#[derive(serde::Deserialize, serde::Serialize)]
pub struct StoriesResponse {
    stories: Vec<StoryResponseData>,
}

impl From<Vec<StoredStory>> for StoriesResponse {
    fn from(stored: Vec<StoredStory>) -> Self {
        Self {
            stories: stored.into_iter().map(StoryResponseData::from).collect(),
        }
    }
}
