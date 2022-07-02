use chrono::{DateTime, Utc};
use serde::{Serialize, Serializer};

use crate::api::{
    review_emotion::ReviewEmotionData,
    shared::long_form_text::LongFormText,
    stories::{NewStory, StoryResponseData},
    users::model::UserProfileData,
    UserId,
};

use super::ReviewSlug;

pub struct NewReview {
    pub body: LongFormText,
    pub story: NewStory,
    pub slug: ReviewSlug,
    pub user_id: UserId,
}

pub struct UpdateReview {
    pub story: Option<NewStory>,
    pub body: Option<LongFormText>,
}

#[derive(Debug)]
pub struct StoredReview {
    pub id: sqlx::types::Uuid,
    pub story_id: sqlx::types::Uuid,
    pub slug: String,
    pub body: String,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub user_id: sqlx::types::Uuid,
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

pub struct CompleteReviewData {
    pub stored_review: StoredReview,
    pub emotions: Vec<ReviewEmotionData>,
    pub story: StoryResponseData,
    pub user: UserProfileData,
}

impl From<CompleteReviewData> for ReviewResponseData {
    fn from(complete_review: CompleteReviewData) -> Self {
        Self {
            story: complete_review.story,
            slug: complete_review.stored_review.slug,
            body: complete_review.stored_review.body,
            created_at: ResponseTime(complete_review.stored_review.created_at),
            updated_at: ResponseTime(complete_review.stored_review.updated_at),
            emotions: complete_review.emotions,
            user: complete_review.user,
        }
    }
}

#[derive(serde::Deserialize, serde::Serialize)]
pub struct ReviewsResponse {
    reviews: Vec<ReviewResponseData>,
}

impl From<Vec<CompleteReviewData>> for ReviewsResponse {
    fn from(stored: Vec<CompleteReviewData>) -> Self {
        Self {
            reviews: stored.into_iter().map(ReviewResponseData::from).collect(),
        }
    }
}
