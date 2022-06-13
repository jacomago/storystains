use std::collections::HashMap;

use serde::Serialize;
use strum::{EnumProperty, IntoEnumIterator};
use strum_macros::{Display, EnumIter, EnumProperty, EnumString};

//TODO refactor to be a combination of the first six emotions with different amounts
#[derive(
    Debug,
    PartialEq,
    Serialize,
    EnumIter,
    EnumString,
    Display,
    Clone,
    Copy,
    EnumProperty,
    Eq,
    PartialOrd,
    Ord,
    Hash,
)]
pub enum Emotion {
    #[strum(props(description = "Strong displeasure against a someone or something."))]
    Anger = 1,
    #[strum(props(description = "An aversion to something distasteful."))]
    Disgust = 2,
    #[strum(props(description = "To expect danger."))]
    Fear = 3,
    #[strum(props(description = "Strong pleasure."))]
    Joy = 4,
    #[strum(props(description = "Unhappiness."))]
    Sadness = 5,
    #[strum(props(description = "Reaction to an unexpected event."))]
    Surprise = 6,
    #[strum(props(description = "Combination of Anger and disgust."))]
    Outrage = 7,
    #[strum(props(description = "Combination of Anger and Fear."))]
    Trapped = 8,
    #[strum(props(description = "Combination of Anger and Joy."))]
    Cruelty = 9,
    #[strum(props(description = "Combination of Anger and Sadness."))]
    Betrayl = 10,
    #[strum(
        serialize = "What the?",
        props(description = "Combination of Anger and Surprise.")
    )]
    WhatThe = 11,
    #[strum(props(description = "Combination of Disgust and Fear."))]
    Horror = 12,
    #[strum(props(description = "Combination of Disgust and Joy."))]
    Eww = 13,
    #[strum(
        serialize = "Pain Empathy",
        props(description = "Combination of Disgust and Sadness.")
    )]
    PainEmpathy = 14,
    #[strum(
        serialize = "You ate it!",
        props(description = "Combination of Disgust and Surprise.")
    )]
    YouAteIt = 15,
    #[strum(props(description = "Combination of Fear and Joy."))]
    Desperation = 16,
    #[strum(props(description = "Combination of Fear and Sadness."))]
    Devastation = 17,
    #[strum(props(description = "Combination of Fear and Surprise."))]
    Spooked = 18,
    #[strum(
        serialize = "Faint Hope",
        props(description = "Combination of Joy and Sadness.")
    )]
    FaintHope = 19,
    #[strum(props(description = "Combination of Joy and Surprise."))]
    Amazement = 20,
    #[strum(props(description = "Combination of Sadness and Surprise."))]
    Disappointment = 21,
}

pub fn emotions() -> Vec<Emotion> {
    Emotion::iter().collect()
}

pub struct StoredEmotion {
    id: i32,
    name: String,
    description: String,
}

pub fn stored_emotions() -> HashMap<Emotion, StoredEmotion> {
    emotions()
        .into_iter()
        .map(|f| {
            (
                f,
                StoredEmotion {
                    id: f as i32,
                    name: f.to_string(),
                    description: f.get_str("description").unwrap().to_string(),
                },
            )
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use std::str::FromStr;

    use strum::EnumProperty;

    use crate::api::emotions::model::Emotion;

    #[test]
    fn string_representation_correct_for_whitespace() {
        let s = Emotion::FaintHope;
        assert_eq!(format!("{}", s), "Faint Hope");
    }
    #[test]
    fn string_representation_correct_for_exclamation() {
        let s = Emotion::YouAteIt;
        assert_eq!(format!("{}", s), "You ate it!");
    }
    #[test]
    fn string_representation_correct_for_question() {
        let s = Emotion::WhatThe;
        assert_eq!(format!("{}", s), "What the?");
    }

    #[test]
    fn mapping_with_whitespace() {
        let s = Emotion::FaintHope;
        assert_eq!(s, Emotion::from_str("Faint Hope").unwrap());
    }
    #[test]
    fn mapping_with_exclamation() {
        let s = Emotion::YouAteIt;
        assert_eq!(s, Emotion::from_str("You ate it!").unwrap());
    }
    #[test]
    fn mapping_with_question() {
        let s = Emotion::WhatThe;
        assert_eq!(s, Emotion::from_str("What the?").unwrap());
    }

    #[test]
    fn description() {
        let s = Emotion::Desperation;
        assert_eq!(
            s.get_str("description").unwrap(),
            "Combination of Fear and Joy."
        );
    }
    #[test]
    fn description_with_serialize() {
        let s = Emotion::WhatThe;
        assert_eq!(
            s.get_str("description").unwrap(),
            "Combination of Anger and Surprise."
        );
    }
}
