use super::{ReviewSlug, ReviewText, ReviewTitle};

pub struct NewReview {
    pub text: ReviewText,
    pub title: ReviewTitle,
    pub slug: ReviewSlug,
}

pub struct UpdateReview {
    pub text: Option<ReviewText>,
    pub title: Option<ReviewTitle>,
    pub slug: Option<ReviewSlug>,
}
