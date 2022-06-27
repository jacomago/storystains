use crate::api::{
    emotions::{Emotion, EmotionData, StoredEmotion},
    LongFormText,
};

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
    pub emotion: EmotionData,
    pub position: i32,
    pub notes: Option<String>,
}

#[derive(serde::Deserialize, serde::Serialize)]
pub struct ReviewEmotionResponse {
    pub review_emotion: ReviewEmotionData,
}

pub struct StoredReviewEmotion {
    pub emotion_id: i32,
    pub position: i32,
    pub notes: Option<String>,
}

impl From<(StoredReviewEmotion, StoredEmotion)> for ReviewEmotionData {
    fn from((stored, emotion): (StoredReviewEmotion, StoredEmotion)) -> Self {
        Self {
            emotion: emotion.into(),
            position: stored.position,
            notes: stored.notes,
        }
    }
}
