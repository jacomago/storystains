use super::{NewPassword, NewUsername};

/// Stored User represents the main information of the user from the database
#[derive(Debug, Clone)]
pub struct StoredUser {
    /// User id of the user
    pub user_id: sqlx::types::Uuid,
    /// User name of the user
    pub username: String,
}

#[derive(serde::Deserialize, serde::Serialize)]
pub struct UserResponse {
    user: UserProfileData,
}

impl From<StoredUser> for UserResponse {
    fn from(user: StoredUser) -> Self {
        Self {
            user: UserProfileData::from(user),
        }
    }
}

pub struct NewUser {
    pub username: NewUsername,
    pub password: NewPassword,
}

#[derive(serde::Deserialize, serde::Serialize)]
pub struct UserProfileData {
    pub username: String,
}

impl From<StoredUser> for UserProfileData {
    fn from(user: StoredUser) -> Self {
        Self {
            username: user.username,
        }
    }
}
