use crate::api::{emotions::Emotion, LongFormText};

use super::EmotionPosition;

pub struct NewReviewEmotion {
    pub emotion: Emotion,
    pub position: EmotionPosition,
    pub notes: Option<LongFormText>,
}

pub struct UpdateReviewEmotion {
    pub emotion: Option<Emotion>,
    pub position: Option<EmotionPosition>,
    pub notes: Option<LongFormText>,
}

#[derive(serde::Deserialize, serde::Serialize)]
pub struct ReviewEmotionData {
    pub emotion: String,
    pub position: i32,
    pub notes: Option<String>,
}

#[derive(serde::Deserialize, serde::Serialize)]
pub struct ReviewEmotionResponse {
    pub review_emotion: ReviewEmotionData,
}

pub struct StoredReviewEmotion {
    pub emotion: String,
    pub position: i32,
    pub notes: Option<String>,
}

impl From<StoredReviewEmotion> for ReviewEmotionData {
    fn from(stored: StoredReviewEmotion) -> Self {
        Self {
            emotion: stored.emotion,
            position: stored.position,
            notes: stored.notes,
        }
    }
}
