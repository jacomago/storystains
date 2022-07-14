use crate::api::shared::{short_form_text::ShortFormText, QueryLimits};

#[derive(serde::Deserialize, serde::Serialize)]
pub struct StoryResponse {
    pub story: StoryResponseData,
}

#[derive(serde::Deserialize, serde::Serialize, Debug)]
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
    pub medium: String,
    pub creator: String,
}

impl From<StoredStory> for StoryResponseData {
    fn from(stored: StoredStory) -> Self {
        Self {
            title: stored.title,
            medium: stored.medium,
            creator: stored.creator,
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

/// Story query options
#[derive(serde::Deserialize, serde::Serialize, Debug, PartialEq)]
pub struct StoryQuery {
    /// Story title matching string
    pub title: Option<String>,
    /// Story title matching medium - must match a medium
    pub medium: Option<String>,
    /// Story creator matching string
    pub creator: Option<String>,
    /// Standard pagination limits
    pub limit: Option<u64>,
    pub offset: Option<u64>,
}

impl StoryQuery {
    // due to bug https://github.com/serde-rs/serde/issues/1183
    // currently cannot use serde(flatten) with non strings
    pub fn query_limits(&self) -> QueryLimits {
        QueryLimits {
            limit: self.limit,
            offset: self.offset,
        }
    }
}

#[cfg(test)]
mod tests {

    use super::StoryQuery;
    use actix_web::web::Query;

    #[test]
    fn test_limit_string() {
        let text = "limit=10".to_string();
        assert_eq!(
            Query::<StoryQuery>::from_query(&text).unwrap().0,
            StoryQuery {
                title: None,
                medium: None,
                creator: None,
                limit: Some(10),
                offset: None
            }
        );
    }
}
