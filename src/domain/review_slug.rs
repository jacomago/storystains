use once_cell::sync::OnceCell;
use regex::Regex;
use std::fmt::Display;
use unicode_segmentation::UnicodeSegmentation;

const SLUG_VALIDATION_REGEX: &str = r#"^[a-z0-9]+(?:-[a-z0-9]+)*$"#;

fn slug_regex() -> &'static Regex {
    static REGEX: OnceCell<Regex> = OnceCell::new();
    REGEX.get_or_init(|| {
        Regex::new(SLUG_VALIDATION_REGEX).expect("slug validation regex should be valid")
    })
}

#[derive(Debug)]
pub struct ReviewSlug(String);

impl AsRef<str> for ReviewSlug {
    fn as_ref(&self) -> &str {
        &self.0
    }
}

impl Display for ReviewSlug {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        self.0.fmt(f)
    }
}

impl ReviewSlug {
    /// Returns an instance of `ReviewSlug` if the input satisfies all
    /// our validation constraints on subscriber slugs.
    /// It panics otherwise.
    pub fn parse(s: String) -> Result<ReviewSlug, String> {
        let is_too_long = s.graphemes(true).count() > 256;
        if !slug_regex().is_match(&s) || is_too_long {
            Err(format!("{} is not a valid review slug.", s))
        } else {
            Ok(Self(s))
        }
    }
}
#[cfg(test)]
mod tests {
    use crate::domain::ReviewSlug;
    use claim::{assert_err, assert_ok};
    #[test]
    fn a_256_grapheme_long_slug_is_invalid() {
        let slug = "�".repeat(256);
        assert_err!(ReviewSlug::parse(slug));
    }
    #[test]
    fn a_slug_longer_than_256_graphemes_is_rejected() {
        let slug = "a".repeat(257);
        assert_err!(ReviewSlug::parse(slug));
    }
    #[test]
    fn whitespace_only_slugs_are_rejected() {
        let slug = " ".to_string();
        assert_err!(ReviewSlug::parse(slug));
    }
    #[test]
    fn empty_string_is_rejected() {
        let slug = "".to_string();
        assert_err!(ReviewSlug::parse(slug));
    }
    #[test]
    fn slugs_containing_an_invalid_character_are_rejected() {
        for slug in &['/', '(', ')', '"', '<', '>', '\\', '{', '}', ' '] {
            let slug = slug.to_string();
            assert_err!(ReviewSlug::parse(slug));
        }
    }
    #[test]
    fn a_valid_slug_is_parsed_successfully() {
        let slug = "lord-of-the-rings".to_string();
        assert_ok!(ReviewSlug::parse(slug));
    }
}
