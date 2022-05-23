use unicode_segmentation::UnicodeSegmentation;

#[derive(Debug)]
pub struct ReviewText(String);

impl ReviewText {
    pub fn parse(s: String) -> Result<ReviewText, String> {
        // `.trim()` returns a view over the input `s` without trailing
        // whitespace-like characters.
        // `.is_empty` checks if the view contains any character.
        let is_empty_or_whitespace = s.trim().is_empty();
        // A grapheme is defined by the Unicode standard as a "user-perceived"
        // character: `å` is a single grapheme, but it is composed of two characters
        // (`a` and `̊`).
        //
        // `graphemes` returns an iterator over the graphemes in the input `s`.
        // `true` specifies that we want to use the extended grapheme definition set,
        // the recommended one.
        let is_too_long = s.graphemes(true).count() > 256000;
        // Iterate over all characters in the input `s` to check if any of them matches
        // one of the characters in the forbidden array.
        let forbidden_characters = ['/', '(', ')', '"', '<', '>', '\\', '{', '}'];
        let contains_forbidden_characters = s.chars().any(|g| forbidden_characters.contains(&g));

        if is_empty_or_whitespace || is_too_long || contains_forbidden_characters {
            Err(format!("{} is not a valid review.", s))
        } else {
            Ok(Self(s))
        }
    }
}

impl AsRef<str> for ReviewText {
    fn as_ref(&self) -> &str {
        &self.0
    }
}

#[cfg(test)]
mod tests {
    use super::ReviewText;
    use claim::{assert_err, assert_ok};
    use fake::faker::lorem::en::Paragraphs;
    use fake::Fake;

    #[test]
    fn empty_string_is_rejected() {
        let review = "".to_string();
        assert_err!(ReviewText::parse(review));
    }

    #[test]
    fn basic_string_is_accepted() {
        let review = "It was rubbish!".to_string();
        assert_ok!(ReviewText::parse(review));
    }

    #[test]
    fn whitespace_only_reviews_are_rejected() {
        let review = " ".to_string();
        assert_err!(ReviewText::parse(review));
    }


    #[test]
    fn a_review_longer_than_256000_graphemes_is_rejected() {
        let review = "a".repeat(256001);
        assert_err!(ReviewText::parse(review));
    }

    #[derive(Debug, Clone)]
    struct ValidReviewFixture(pub String);

    impl quickcheck::Arbitrary for ValidReviewFixture {
        fn arbitrary(_: &mut quickcheck::Gen) -> Self {
            let review_paras: Vec<String> = Paragraphs(10..50).fake();
            let review = review_paras.join("\n");
            Self(review)
        }

        fn shrink(&self) -> Box<dyn Iterator<Item = Self>> {
            quickcheck::empty_shrinker()
        }
    }

    #[quickcheck_macros::quickcheck]
    fn valid_reviews_are_parsed_successfully(valid_review: ValidReviewFixture) -> bool {
        ReviewText::parse(valid_review.0).is_ok()
    }
}
