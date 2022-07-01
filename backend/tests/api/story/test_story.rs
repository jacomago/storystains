use fake::{faker, Fake};
use serde::{Deserialize, Serialize};

pub fn story_relative_url(slug: &str) -> String {
    format!("/stories/{}", slug)
}

pub fn story_relative_url_prefix() -> String {
    "/stories".to_string()
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct TestStory {
    pub title: String,
    pub creator: String,
    pub medium: String,
}

impl PartialEq for TestStory {
    fn eq(&self, other: &Self) -> bool {
        self.title == other.title && self.creator == other.creator && self.medium == other.medium
    }
}

impl TestStory {
    pub fn generate() -> Self {
        TestStory {
            title: faker::lorem::en::Word().fake(),
            creator: "Anonymous".to_string(),
            medium: "Book".to_string(),
        }
    }
}
