use std::fmt::Display;

use slug::slugify;
use unicode_segmentation::UnicodeSegmentation;

#[derive(Debug)]
pub struct ReviewTitle(String);

impl AsRef<str> for ReviewTitle {
    fn as_ref(&self) -> &str {
        &self.0
    }
}

impl Display for ReviewTitle {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        self.0.fmt(f)
    }
}

impl ReviewTitle {
    /// Returns an instance of `ReviewTitle` if the input satisfies all
    /// our validation constraints on subscriber titles.
    /// It panics otherwise.
    pub fn parse(s: String) -> Result<ReviewTitle, String> {
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
            Err(format!("{} is not a valid review title.", s))
        } else {
            Ok(Self(s))
        }
    }

    pub fn slugify(&self) -> String {
        slugify(self.as_ref())
    }
}
#[cfg(test)]
mod tests {
    use claim::{assert_err, assert_ok};

    use crate::api::reviews::model::review_title::ReviewTitle;
    #[test]
    fn a_256_grapheme_long_title_is_valid() {
        let title = "�".repeat(256);
        assert_ok!(ReviewTitle::parse(title));
    }
    #[test]
    fn a_title_longer_than_256_graphemes_is_rejected() {
        let title = "a".repeat(257);
        assert_err!(ReviewTitle::parse(title));
    }
    #[test]
    fn whitespace_only_titles_are_rejected() {
        let title = " ".to_string();
        assert_err!(ReviewTitle::parse(title));
    }
    #[test]
    fn empty_string_is_rejected() {
        let title = "".to_string();
        assert_err!(ReviewTitle::parse(title));
    }
    #[test]
    fn titles_containing_an_invalid_character_are_rejected() {
        for title in &['/', '(', ')', '"', '<', '>', '\\', '{', '}'] {
            let title = title.to_string();
            assert_err!(ReviewTitle::parse(title));
        }
    }
    #[test]
    fn a_valid_title_is_parsed_successfully() {
        let title = "Lord of the Rings".to_string();
        assert_ok!(ReviewTitle::parse(title));
    }
}
