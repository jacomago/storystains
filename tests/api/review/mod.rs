use chrono::{DateTime, Utc};
use fake::{faker, Fake};
use reqwest::StatusCode;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};

use crate::helpers::{TestApp, TestUser};

mod delete;
mod get;
mod get_list;
mod post;
mod put;

#[derive(Debug, Serialize, Deserialize)]
pub struct TestReviewResponse {
    review: TestReview,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct TestReview {
    title: String,
    body: String,
    slug: String,
    created_at: DateTime<Utc>,
    updated_at: DateTime<Utc>,
}

impl TestReview {
    fn create_json(&self) -> Value {
        json!({"review": {"title": self.title.to_string(), "body":self.body.to_string()}})
    }

    fn generate() -> Self {
        let title: String = faker::lorem::en::Word().fake();
        Self {
            title: title.to_string(),
            body: faker::lorem::en::Paragraphs(1..3)
                .fake::<Vec<String>>()
                .join("\n"),
            slug: title,
            created_at: Utc::now(),
            updated_at: Utc::now(),
        }
    }

    async fn store(&self, app: &TestApp, user: &TestUser) {
        let token = user.login(app).await;

        let body = self.create_json();
        // Act
        let response = app.post_review(body.to_string(), &token).await;

        // Assert
        assert_eq!(response.status(), StatusCode::OK);
    }
}

impl PartialEq for TestReview {
    fn eq(&self, other: &Self) -> bool {
        self.title == other.title
            && self.body == other.body
            && self.slug == other.slug
            && 10 > (self.created_at - other.created_at).num_seconds()
            && 10 > (self.updated_at - other.updated_at).num_seconds()
    }
}
