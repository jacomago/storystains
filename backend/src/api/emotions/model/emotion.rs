#[derive(Clone, Debug, serde::Serialize, PartialEq)]
pub struct StoredEmotion {
    pub id: i32,
    pub name: String,
    pub description: String,
    pub icon_url: String,
    pub joy: i32,
    pub sadness: i32,
    pub anger: i32,
    pub disgust: i32,
    pub surprise: i32,
    pub fear: i32,
}

/// Representation of structure of an emotion in the api
#[derive(Debug, serde::Serialize, serde::Deserialize, PartialEq)]
pub struct EmotionData {
    /// Name of the emotion
    pub name: String,
    /// Description of the emotion
    pub description: String,
    /// Relative url of where the url is being served from
    pub icon_url: String,
    /// Amount of Joy
    pub joy: i32,
    /// Amount of Sadness
    pub sadness: i32,
    /// Amount of Anger
    pub anger: i32,
    /// Amount of disgust
    pub disgust: i32,
    /// Amount of surprise
    pub surprise: i32,
    /// Amount of Fear
    pub fear: i32,
}

impl From<StoredEmotion> for EmotionData {
    fn from(e: StoredEmotion) -> Self {
        Self {
            name: e.name,
            description: e.description,
            icon_url: e.icon_url,
            joy: e.joy,
            anger: e.anger,
            disgust: e.disgust,
            surprise: e.surprise,
            fear: e.fear,
            sadness: e.sadness,
        }
    }
}
