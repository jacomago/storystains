use super::{NewPassword, NewUsername};

#[derive(Debug)]
pub struct StoredUser {
    pub user_id: sqlx::types::Uuid,
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
