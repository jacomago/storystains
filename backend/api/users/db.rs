use crate::api::{users::model::StoredUser, uuid_to_sqlx_uuid};
use anyhow::Context;
use secrecy::{ExposeSecret, Secret};
use sqlx::{PgPool, Postgres, Transaction};
use uuid::Uuid;

use super::{model::NewUser, UserId};

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
    let id = uuid_to_sqlx_uuid(user_id);

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

#[tracing::instrument(name = "Check user exists", skip(user_id, pool))]
pub async fn check_user_exists(user_id: &UserId, pool: &PgPool) -> Result<bool, anyhow::Error> {
    let id = uuid_to_sqlx_uuid(user_id);

    let row = sqlx::query!(
        r#"
            SELECT user_id 
            FROM users
            WHERE user_id = $1
        "#,
        id,
    )
    .fetch_optional(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(row.is_some())
}

#[tracing::instrument(name = "Saving new user details in the database", skip(user, pool))]
pub async fn create_user(user: NewUser, pool: &PgPool) -> Result<StoredUser, anyhow::Error> {
    let id = uuid_to_sqlx_uuid(&Uuid::new_v4());

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

#[tracing::instrument(
    name = "Deleting user details from the database",
    skip(transaction),
    fields(
        user_id = %user_id
    )
)]
pub async fn delete_user_by_id(
    user_id: &Uuid,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<(), sqlx::Error> {
    let id = uuid_to_sqlx_uuid(user_id);

    sqlx::query!(
        r#"
            DELETE FROM users
            WHERE       user_id = $1
        "#,
        id
    )
    .execute(transaction)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(())
}
