use serde::Serialize;
use strum::IntoEnumIterator;
use strum_macros::{Display, EnumIter, EnumString};

#[derive(Debug, PartialEq, Serialize, EnumIter, EnumString, Display, Clone, Copy)]
pub enum Emotion {
    Anger = 1,
    Disgust = 2,
    Fear = 3,
    Joy = 4,
    Sadness = 5,
    Surprise = 6,
    Outrage = 7,
    Trapped = 8,
    Cruelty = 9,
    Betrayl = 10,
    #[strum(serialize = "What the?")]
    WhatThe = 11,
    Horror = 12,
    Eww = 13,
    #[strum(serialize = "Pain Empathy")]
    PainEmpathy = 14,
    #[strum(serialize = "You ate it!")]
    YouAteIt = 15,
    Desperation = 16,
    Devastation = 17,
    Spooked = 18,
    #[strum(serialize = "Faint Hope")]
    FaintHope = 19,
    Amazement = 20,
    Disappointment = 21,
}

pub fn emotions() -> Vec<Emotion> {
    Emotion::iter().collect()
}

#[cfg(test)]
mod tests {
    use std::str::FromStr;

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
}
