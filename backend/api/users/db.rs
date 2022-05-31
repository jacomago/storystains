use crate::api::users::model::StoredUser;
use anyhow::Context;
use secrecy::{ExposeSecret, Secret};
use sqlx::PgPool;
use uuid::Uuid;

use super::model::NewUser;

#[tracing::instrument(name = "Get stored credentials", skip(username, pool))]
pub async fn get_stored_credentials(
    username: &str,
    pool: &PgPool,
) -> Result<Option<(uuid::Uuid, Secret<String>)>, anyhow::Error> {
    let row = sqlx::query!(
        r#"
        SELECT user_id, password_hash FROM users
        WHERE username = $1
        "#,
        username,
    )
    .fetch_optional(pool)
    .await
    .context("Failed to perform a query to retrieve stored credentials.")?
    .map(|row| {
        (
            Uuid::from_u128(row.user_id.as_u128()),
            Secret::new(row.password_hash),
        )
    });
    Ok(row)
}

#[tracing::instrument(name = "Read user details from db", skip(user_id, pool))]
pub async fn read_user_from_id(user_id: &Uuid, pool: &PgPool) -> Result<StoredUser, anyhow::Error> {
    let id: sqlx::types::Uuid = sqlx::types::Uuid::from_u128(user_id.as_u128());

    let row = sqlx::query_as!(
        StoredUser,
        r#"
        SELECT user_id, username 
        FROM users
        WHERE user_id = $1
        "#,
        id,
    )
    .fetch_one(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(row)
}

#[tracing::instrument(name = "Saving new user details in the database", skip(user, pool))]
pub async fn create_user(user: NewUser, pool: &PgPool) -> Result<StoredUser, anyhow::Error> {
    let id: sqlx::types::Uuid = sqlx::types::Uuid::from_u128(Uuid::new_v4().as_u128());

    let password_hash = user.password.hash().await?;
    let stored_user = sqlx::query_as!(
        StoredUser,
        r#"
            INSERT INTO users (user_id, username, password_hash)
            VALUES ($1, $2, $3)
            RETURNING user_id, username
        "#,
        id,
        user.username.as_ref(),
        password_hash.expose_secret(),
    )
    .fetch_one(pool)
    .await
    .context("Failed to store user.")?;
    Ok(stored_user)
}
