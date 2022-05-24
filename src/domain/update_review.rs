use super::{ReviewSlug, ReviewText, ReviewTitle};

pub struct UpdateReview {
    pub text: Option<ReviewText>,
    pub title: Option<ReviewTitle>,
    pub slug: Option<ReviewSlug>,
}
