use std::fmt::Display;

/// List of all available Emotion names in the DB
pub const EMOTION_STRINGS: [&str; 39] = [
    "Anger",
    "Disgust",
    "Fear",
    "Joy",
    "Sadness",
    "Surprise",
    "Outrage",
    "Trapped",
    "Cruelty",
    "Betrayal",
    "What the?",
    "Horror",
    "Eww",
    "Pain Empathy",
    "You ate it!",
    "Desperation",
    "Devastation",
    "Spooked",
    "Faint Hope",
    "Amazement",
    "Disappointment",
    "Sternness",
    "Indignation",
    "Rage",
    "Disdain",
    "Aversion",
    "Revulsion",
    "Concern",
    "Anxiety",
    "Terror",
    "Satisfaction",
    "Amusement",
    "Laughter",
    "Dejection",
    "Melancholy",
    "Grief",
    "Alertness",
    "Wonder",
    "Shock",
];

#[derive(Debug)]
pub struct EmotionName(String);

impl AsRef<str> for EmotionName {
    fn as_ref(&self) -> &str {
        &self.0
    }
}

impl Display for EmotionName {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        self.0.fmt(f)
    }
}

impl EmotionName {
    /// Returns an instance of `EmotionName` if the input satisfies all
    /// our validation constraints on emotion positions.
    /// It panics otherwise.
    pub fn parse(name: String) -> Result<EmotionName, String> {
        if EMOTION_STRINGS.contains(&name.as_ref()) {
            Ok(EmotionName(name))
        } else {
            Err(format!("{} is not a valid emotion name.", name))
        }
    }
}

#[cfg(test)]
mod tests {
    use claim::{assert_err, assert_ok};

    use crate::api::emotions::model::{EmotionName, EMOTION_STRINGS};

    #[test]
    fn empty_string_is_invalid() {
        assert_err!(EmotionName::parse("".to_string()));
    }

    #[test]
    fn string_not_in_list_is_invalid() {
        assert_err!(EmotionName::parse("Word".to_string()));
    }

    #[test]
    fn all_elements_of_list_work() {
        for e in EMOTION_STRINGS {
            assert_ok!(EmotionName::parse(e.to_string()));
        }
    }
}
