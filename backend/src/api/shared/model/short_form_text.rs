use std::fmt::Display;

use slug::slugify;
use unicode_segmentation::UnicodeSegmentation;

#[derive(Debug)]
pub struct ShortFormText(String);

impl AsRef<str> for ShortFormText {
    fn as_ref(&self) -> &str {
        &self.0
    }
}

impl Display for ShortFormText {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        self.0.fmt(f)
    }
}

impl ShortFormText {
    /// Returns an instance of `ShortFormText` if the input satisfies all
    /// our validation constraints on short form texts.
    /// It panics otherwise.
    pub fn parse(s: String) -> Result<ShortFormText, String> {
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
        let is_too_long = s.graphemes(true).count() > 256;
        // Iterate over all characters in the input `s` to check if any of them matches
        // one of the characters in the forbidden array.
        let forbidden_characters = ['/', '(', ')', '"', '<', '>', '\\', '{', '}'];
        let contains_forbidden_characters = s.chars().any(|g| forbidden_characters.contains(&g));

        if is_empty_or_whitespace || is_too_long || contains_forbidden_characters {
            Err(format!("{} is not a valid review text.", s))
        } else {
            Ok(Self(s.trim().to_string()))
        }
    }

    pub fn slugify(&self) -> String {
        slugify(self.as_ref())
    }
}

#[cfg(test)]
mod tests {
    use claim::{assert_err, assert_ok};

    use crate::api::shared::short_form_text::ShortFormText;

    #[test]
    fn a_256_grapheme_long_text_is_valid() {
        let text = "�".repeat(256);
        assert_ok!(ShortFormText::parse(text));
    }
    #[test]
    fn a_text_longer_than_256_graphemes_is_rejected() {
        let text = "a".repeat(257);
        assert_err!(ShortFormText::parse(text));
    }
    #[test]
    fn whitespace_only_texts_are_rejected() {
        let text = " ".to_string();
        assert_err!(ShortFormText::parse(text));
    }
    #[test]
    fn empty_string_is_rejected() {
        let text = "".to_string();
        assert_err!(ShortFormText::parse(text));
    }
    #[test]
    fn texts_containing_an_invalid_character_are_rejected() {
        for text in &['/', '(', ')', '"', '<', '>', '\\', '{', '}'] {
            let text = text.to_string();
            assert_err!(ShortFormText::parse(text));
        }
    }
    #[test]
    fn a_valid_text_is_parsed_successfully() {
        let text = "Lord of the Rings".to_string();
        assert_ok!(ShortFormText::parse(text));
    }
}
