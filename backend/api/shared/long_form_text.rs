use std::fmt::Display;

use unicode_segmentation::UnicodeSegmentation;

/// Struct for any long form text in the application
/// cannot be only whitespace
/// cannot be too long
/// cannot contain forbidden characters
#[derive(Debug)]
pub struct LongFormText(String);

impl LongFormText {
    /// Parse a string into a Long form text to confirm it follows guidlines for long form text
    pub fn parse(s: String) -> Result<LongFormText, String> {
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
            Err(format!("{} is not a valid text.", s))
        } else {
            Ok(Self(s))
        }
    }
}

impl AsRef<str> for LongFormText {
    fn as_ref(&self) -> &str {
        &self.0
    }
}

impl Display for LongFormText {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        self.0.fmt(f)
    }
}
#[cfg(test)]
mod tests {
    use super::LongFormText;
    use claim::{assert_err, assert_ok};
    use fake::faker::lorem::en::Paragraphs;
    use fake::Fake;

    #[test]
    fn empty_string_is_rejected() {
        let text = "".to_string();
        assert_err!(LongFormText::parse(text));
    }

    #[test]
    fn basic_string_is_accepted() {
        let text = "It was rubbish!".to_string();
        assert_ok!(LongFormText::parse(text));
    }

    #[test]
    fn whitespace_only_texts_are_rejected() {
        let text = " ".to_string();
        assert_err!(LongFormText::parse(text));
    }

    #[test]
    fn a_text_longer_than_256000_graphemes_is_rejected() {
        let text = "a".repeat(256001);
        assert_err!(LongFormText::parse(text));
    }

    #[derive(Debug, Clone)]
    struct ValidFixture(pub String);

    impl quickcheck::Arbitrary for ValidFixture {
        fn arbitrary(_: &mut quickcheck::Gen) -> Self {
            let text_paras: Vec<String> = Paragraphs(10..50).fake();
            let text = text_paras.join("\n");
            Self(text)
        }

        fn shrink(&self) -> Box<dyn Iterator<Item = Self>> {
            quickcheck::empty_shrinker()
        }
    }

    #[quickcheck_macros::quickcheck]
    fn valid_texts_are_parsed_successfully(valid_text: ValidFixture) -> bool {
        LongFormText::parse(valid_text.0).is_ok()
    }
}
