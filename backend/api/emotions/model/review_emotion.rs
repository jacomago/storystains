use crate::api::LongFormText;

use super::{Emotion, EmotionPosition};

pub struct NewReviewEmotion {
    pub emotion: Emotion,
    pub position: EmotionPosition,
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

impl From<&NewReviewEmotion> for StoredReviewEmotion {
    fn from(review_emotion: &NewReviewEmotion) -> Self {
        Self {
            emotion: review_emotion.emotion.to_string(),
            position: *review_emotion.position.as_ref(),
            notes: review_emotion.notes.map(|n| n.to_string()),
        }
    }
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
