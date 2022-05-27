use std::ops::Deref;

use uuid::Uuid;

use super::{NewPassword, NewUsername};

#[derive(Copy, Clone, Debug, serde::Serialize)]
pub struct UserId(Uuid);

impl UserId {
    pub fn new(uuid: Uuid) -> Self {
        Self(uuid)
    }
}

impl std::fmt::Display for UserId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        self.0.fmt(f)
    }
}

impl Deref for UserId {
    type Target = Uuid;
    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl TryFrom<UserId> for sqlx::types::Uuid {
    type Error = String;
    fn try_from(value: UserId) -> Result<Self, Self::Error> {
        let id = sqlx::types::Uuid::from_u128(value.0.as_u128());
        Ok(id)
    }
}

#[derive(serde::Deserialize, serde::Serialize)]
pub struct StoredUser {
    pub username: String,
}

#[derive(serde::Deserialize, serde::Serialize)]
pub struct UserResponse {
    user: UserResponseData,
}

impl From<StoredUser> for UserResponse {
    fn from(stored: StoredUser) -> Self {
        Self {
            user: UserResponseData {
                username: stored.username,
            },
        }
    }
}

#[derive(serde::Deserialize, serde::Serialize)]
pub struct UserResponseData {
    username: String,
}

pub struct NewUser {
    pub username: NewUsername,
    pub password: NewPassword,
}
