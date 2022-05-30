use chrono::{DateTime, Utc};
use serde::{Serialize, Serializer};

use crate::api::UserId;

use super::{ReviewSlug, ReviewText, ReviewTitle};

pub struct NewReview {
    pub text: ReviewText,
    pub title: ReviewTitle,
    pub slug: ReviewSlug,
    pub user_id: UserId,
}

pub struct UpdateReview {
    pub text: Option<ReviewText>,
    pub title: Option<ReviewTitle>,
    pub slug: Option<ReviewSlug>,
}

#[derive(Debug)]
pub struct StoredReview {
    pub title: String,
    pub slug: String,
    pub review: String,
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
    review: ReviewResponseData,
}

impl From<StoredReview> for ReviewResponse {
    fn from(stored: StoredReview) -> Self {
        Self {
            review: ReviewResponseData {
                title: stored.title,
                slug: stored.slug,
                review: stored.review,
                created_at: ResponseTime(stored.created_at),
                updated_at: ResponseTime(stored.updated_at),
            },
        }
    }
}

#[derive(serde::Deserialize, serde::Serialize)]
pub struct ReviewResponseData {
    title: String,
    slug: String,
    review: String,
    created_at: ResponseTime,
    updated_at: ResponseTime,
}
