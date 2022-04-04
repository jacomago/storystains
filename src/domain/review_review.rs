
#[derive(Debug)]
pub struct ReviewReview(String);

impl ReviewReview {
    pub fn parse(s: String) -> Result<ReviewReview, String> {
        if validate_review(&s) {
            Ok(Self(s))
        } else {
            Err(format!("{} is not a valid subscriber review.", s))
        }
    }
}

impl AsRef<str> for ReviewReview {
    fn as_ref(&self) -> &str {
        &self.0
    }
}

#[cfg(test)]
mod tests {
    use super::ReviewReview;
    use claim::assert_err;
    use fake::faker::Words;
    use fake::Fake;

    #[test]
    fn empty_string_is_rejected() {
        let review = "".to_string();
        assert_err!(ReviewReview::parse(review));
    }
    #[test]
    fn review_missing_at_symbol_is_rejected() {
        let review = "ursuladomain.com".to_string();
        assert_err!(ReviewReview::parse(review));
    }
    #[test]
    fn review_missing_subject_is_rejected() {
        let review = "@domain.com".to_string();
        assert_err!(ReviewReview::parse(review));
    }

    #[derive(Debug, Clone)]
    struct ValidReviewFixture(pub String);

    impl quickcheck::Arbitrary for ValidReviewFixture {
        fn arbitrary<G: quickcheck::Gen>(g: &mut G) -> Self {
            let review = SafeReview().fake_with_rng(g);
            Self(review)
        }
    }

    #[quickcheck_macros::quickcheck]
    fn valid_reviews_are_parsed_successfully(valid_review: ValidReviewFixture) -> bool {
        ReviewReview::parse(valid_review.0).is_ok()
    }
}
