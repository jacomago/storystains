use sqlx::{PgPool, Postgres, Transaction};

use super::model::StoredEmotion;

#[tracing::instrument(name = "Get all emotions from the db", skip(pool))]
pub async fn retreive_all_emotions(pool: &PgPool) -> Result<Vec<StoredEmotion>, sqlx::Error> {
    let stored = sqlx::query_as!(
        StoredEmotion,
        r#"
            SELECT id, name, description, icon_url
            FROM emotions
        "#
    )
    .fetch_all(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(stored)
}

#[tracing::instrument(name = "Get emotion details from the db", skip(transaction))]
pub async fn read_emotion_by_id_trans(
    id: i32,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<StoredEmotion, sqlx::Error> {
    let stored = sqlx::query_as!(
        StoredEmotion,
        r#"
            SELECT id, name, description, icon_url
            FROM emotions
            WHERE id = $1
        "#,
        id
    )
    .fetch_one(transaction)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(stored)
}

#[tracing::instrument(name = "Get emotion details from the db", skip(pool))]
pub async fn read_emotion_by_id_pool(id: i32, pool: &PgPool) -> Result<StoredEmotion, sqlx::Error> {
    let stored = sqlx::query_as!(
        StoredEmotion,
        r#"
            SELECT id, name, description, icon_url
            FROM emotions
            WHERE id = $1
        "#,
        id
    )
    .fetch_one(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(stored)
}
