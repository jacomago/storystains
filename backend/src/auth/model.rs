use secrecy::Secret;

use crate::api::{StoredUser, UserId};

/// Credentials for authentication
pub struct Credentials {
    /// username
    pub username: String,
    /// password as a secret
    pub password: Secret<String>,
}

#[derive(serde::Deserialize, serde::Serialize, Debug, Clone)]
/// User info for validation
pub struct AuthUser {
    /// username
    pub username: String,
    /// User id
    pub user_id: UserId,
}

impl From<StoredUser> for AuthUser {
    fn from(user: StoredUser) -> Self {
        Self {
            username: user.username,
            user_id: UserId(user.user_id),
        }
    }
}
