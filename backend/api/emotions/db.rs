use sqlx::{PgPool, Postgres, Transaction};

use super::model::StoredEmotion;

#[tracing::instrument(name = "Saving all emotions into the db", skip(pool))]
pub async fn store_emotions(
    emotions: Vec<StoredEmotion>,
    pool: &PgPool,
) -> Result<(), sqlx::Error> {
    let ids: Vec<i32> = emotions.iter().map(|e| e.id).collect();
    let names: Vec<String> = emotions.iter().map(|e| e.name.to_string()).collect();
    let descriptions: Vec<String> = emotions.iter().map(|e| e.description.to_string()).collect();
    let icon_urls: Vec<String> = emotions.iter().map(|e| e.icon_url.to_string()).collect();

    sqlx::query!(
        "
        INSERT INTO emotions(id, name, description, icon_url) 
        SELECT * FROM UNNEST($1::integer[], $2::text[], $3::text[], $4::text[])
        ",
        &ids,
        &names,
        &descriptions,
        &icon_urls
    )
    .execute(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(())
}

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
