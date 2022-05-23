use super::{ReviewSlug, ReviewText, ReviewTitle};

pub struct NewReview {
    pub text: ReviewText,
    pub title: ReviewTitle,
    pub slug: ReviewSlug,
}
