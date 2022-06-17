use serde::{Deserialize, Serialize};
use slug::slugify;
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

/// Returns vector of all emotions available
pub fn emotions() -> Vec<Emotion> {
    Emotion::iter().collect()
}

#[derive(Clone, Debug, Serialize, PartialEq)]
pub struct StoredEmotion {
    pub id: i32,
    pub name: String,
    pub description: String,
    pub icon_url: String,
}

/// Representation of structure of an emotion in the api
#[derive(Debug, Serialize, Deserialize, PartialEq)]
pub struct EmotionData {
    /// Name of the emotion
    pub name: String,
    /// Description of the emotion
    pub description: String,
    /// Relative url of where the url is being served from
    pub icon_url: String,
}

impl From<StoredEmotion> for EmotionData {
    fn from(e: StoredEmotion) -> Self {
        Self {
            name: e.name,
            description: e.description,
            icon_url: e.icon_url,
        }
    }
}

impl From<&Emotion> for StoredEmotion {
    fn from(e: &Emotion) -> Self {
        StoredEmotion {
            id: *e as i32,
            name: e.to_string(),
            description: e.get_str("description").unwrap().to_string(),
            icon_url: format!("/emotions/{}.svg", slugify(e.to_string())),
        }
    }
}
impl From<Emotion> for EmotionData {
    fn from(e: Emotion) -> Self {
        EmotionData::from(StoredEmotion::from(&e))
    }
}

pub fn check_emotions(stored_emotions: Vec<StoredEmotion>) -> Result<(), String> {
    let mem_emotions = emotions()
        .iter()
        .map(StoredEmotion::from)
        .collect::<Vec<StoredEmotion>>();
    if stored_emotions != mem_emotions {
        return Err("Stored doesnot match emotions.".to_string());
    }
    Ok(())
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
