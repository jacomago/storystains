use serde::Serialize;
use strum::IntoEnumIterator;
use strum_macros::EnumIter;

#[derive(Debug, PartialEq, Serialize, EnumIter)]
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
    WhatThe = 11,
    Horror = 12,
    Eww = 13,
    PainEmpathy = 14,
    YouAteIt = 15,
    Desperation = 16,
    Devastation = 17,
    Spooked = 18,
    FaintHope = 19,
    Amazement = 20,
    Disappointment = 21,
}

pub fn emotions() -> Vec<Emotion> {
    Emotion::iter().collect()
}
