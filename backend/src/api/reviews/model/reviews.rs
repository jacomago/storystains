use chrono::{DateTime, Utc};
use serde::{Serialize, Serializer};

use crate::api::{
    review_emotion::ReviewEmotionData,
    shared::{long_form_text::LongFormText, short_form_text::ShortFormText},
    stories::StoryResponseData,
    users::model::UserProfileData,
    UserId,
};

use super::ReviewSlug;

pub struct NewReview {
    pub body: LongFormText,
    pub title: ShortFormText,
    pub slug: ReviewSlug,
    pub user_id: UserId,
}

pub struct UpdateReview {
    pub body: Option<LongFormText>,
    pub title: Option<ShortFormText>,
    pub slug: Option<ReviewSlug>,
}

#[derive(Debug)]
pub struct StoredReview {
    pub id: sqlx::types::Uuid,
    pub title: String,
    pub slug: String,
    pub body: String,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub username: String,
}

#[derive(Debug, PartialEq, serde::Deserialize)]
pub struct ResponseTime(DateTime<Utc>);

impl Serialize for ResponseTime {
    fn serialize<S: Serializer>(&self, serializer: S) -> Result<S::Ok, S::Error> {
        let s = self.0.format("%Y-%m-%dT%H:%M:%S.%3fZ");
        serializer.serialize_str(&s.to_string())
    }
}

#[derive(serde::Deserialize, serde::Serialize)]
pub struct ReviewResponse {
    pub review: ReviewResponseData,
}

#[derive(serde::Deserialize, serde::Serialize)]
pub struct ReviewResponseData {
    story: StoryResponseData,
    slug: String,
    body: String,
    created_at: ResponseTime,
    updated_at: ResponseTime,
    emotions: Vec<ReviewEmotionData>,
    user: UserProfileData,
}

impl From<(StoredReview, Vec<ReviewEmotionData>)> for ReviewResponseData {
    fn from((stored, emotions): (StoredReview, Vec<ReviewEmotionData>)) -> Self {
        Self {
            story: StoryResponseData {
                title: stored.title,
                medium: "Book".to_string(),
                creator: "Anonymous".to_string(),
            },
            slug: stored.slug,
            body: stored.body,
            created_at: ResponseTime(stored.created_at),
            updated_at: ResponseTime(stored.updated_at),
            emotions,
            user: UserProfileData {
                username: stored.username,
            },
        }
    }
}

#[derive(serde::Deserialize, serde::Serialize)]
pub struct ReviewsResponse {
    reviews: Vec<ReviewResponseData>,
}

impl From<Vec<(StoredReview, Vec<ReviewEmotionData>)>> for ReviewsResponse {
    fn from(stored: Vec<(StoredReview, Vec<ReviewEmotionData>)>) -> Self {
        Self {
            reviews: stored.into_iter().map(ReviewResponseData::from).collect(),
        }
    }
}
