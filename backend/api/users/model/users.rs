use super::{NewPassword, NewUsername};

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
