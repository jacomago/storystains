use sqlx::{PgPool, QueryBuilder};
use strum::EnumProperty;

use super::model::{Emotion, StoredEmotion};

#[tracing::instrument(name = "Saving all emotions into the db", skip(pool))]
pub async fn store_emotions(emotions: Vec<Emotion>, pool: &PgPool) -> Result<(), sqlx::Error> {
    let mut builder = QueryBuilder::new(
        r#" 
            INSERT INTO emotions(
                id,
                name,
                description
            )
        "#,
    );
    builder.push_values(&emotions, |mut b, e| {
        b.push_bind(*e as i32)
            .push_bind(e.to_string())
            .push_bind(e.get_str("description").unwrap());
    });
    let query = builder.build();
    query.execute(pool).await.map_err(|e| {
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
            SELECT id, name, description
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
