use super::{NewUsername, NewPassword};

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
    pub password: NewPassword
}
