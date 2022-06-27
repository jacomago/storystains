use std::ops::Deref;
/// Format of an id of a user to stay consistent across application
/// with multiple Uuid implementations
#[derive(Copy, Clone, Debug, serde::Serialize, serde::Deserialize, PartialEq, Eq)]
pub struct UserId(uuid::Uuid);

impl UserId {
    /// Generates a new UserId
    pub fn new(uuid: uuid::Uuid) -> Self {
        Self(uuid)
    }
}

impl std::fmt::Display for UserId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        self.0.fmt(f)
    }
}

impl Deref for UserId {
    type Target = uuid::Uuid;
    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl From<UserId> for sqlx::types::Uuid {
    fn from(value: UserId) -> Self {
        sqlx::types::Uuid::from_u128(value.0.as_u128())
    }
}

impl From<sqlx::types::Uuid> for UserId {
    fn from(uuid: sqlx::types::Uuid) -> Self {
        Self(uuid::Uuid::from_u128(uuid.as_u128()))
    }
}
