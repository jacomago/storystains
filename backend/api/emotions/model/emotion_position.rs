use std::fmt::Display;

#[derive(Debug)]
pub struct EmotionPosition(i32);

impl AsRef<i32> for EmotionPosition {
    fn as_ref(&self) -> &i32 {
        &self.0
    }
}

impl Display for EmotionPosition {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        self.0.fmt(f)
    }
}

impl EmotionPosition {
    /// Returns an instance of `EmotionPosition` if the input satisfies all
    /// our validation constraints on emotion positions.
    /// It panics otherwise.
    pub fn parse(i: i32) -> Result<EmotionPosition, String> {
        if validator::validate_range(i, Some(0), Some(100)) {
            Ok(EmotionPosition(i))
        } else {
            Err(format!("{} is not a valid emotion position.", i))
        }
    }
}

#[cfg(test)]
mod tests {
    use claim::{assert_err, assert_ok};

    use crate::api::emotions::model::EmotionPosition;

    #[test]
    fn a_number_between_0_and_100_is_valid() {
        for i in 0..100 {
            assert_ok!(EmotionPosition::parse(i));
        }
    }

    #[test]
    fn a_number_less_than_0_is_rejected() {
        assert_err!(EmotionPosition::parse(-1));
    }
    #[test]
    fn a_number_greater_than_100_is_rejected() {
        assert_err!(EmotionPosition::parse(101));
    }
}
