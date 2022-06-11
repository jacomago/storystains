use std::ops::Deref;

use super::{NewPassword, NewUsername};

/// Format of an id of a user to stay consistent across application
/// with multiple Uuid implementations
#[derive(Copy, Clone, Debug, serde::Serialize, PartialEq, Eq)]
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

#[derive(Debug)]
pub struct StoredUser {
    pub user_id: sqlx::types::Uuid,
    pub username: String,
}

#[derive(serde::Deserialize, serde::Serialize)]
pub struct UserResponse {
    user: UserResponseData,
}

impl From<(StoredUser, String)> for UserResponse {
    fn from(user_token: (StoredUser, String)) -> Self {
        Self {
            user: UserResponseData {
                username: user_token.0.username,
                token: user_token.1,
            },
        }
    }
}

#[derive(serde::Deserialize, serde::Serialize)]
pub struct UserResponseData {
    username: String,
    token: String,
}

pub struct NewUser {
    pub username: NewUsername,
    pub password: NewPassword,
}

#[derive(serde::Deserialize, serde::Serialize)]
pub struct UserProfileData {
    pub username: String,
}
