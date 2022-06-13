use sqlx::{types::Uuid, PgPool, QueryBuilder};
use strum::EnumProperty;

use crate::api::reviews::ReviewSlug;

use super::model::{Emotion, NewReviewEmotion, StoredEmotion, StoredReviewEmotion};

#[tracing::instrument(
    name = "Saving new review emotion details in the database",
    skip(review_emotion, pool)
)]
pub async fn create_review_emotion(
    review_slug: &ReviewSlug,
    review_emotion: &NewReviewEmotion,
    pool: &PgPool,
) -> Result<StoredReviewEmotion, sqlx::Error> {
    let id = Uuid::new_v4();
    let _ = sqlx::query!(
        r#" 
            INSERT INTO review_emotions(
                id,
                review_id,
                emotion_id,
                position,
                notes
            )
            VALUES (
                $1,
                (
                    SELECT id
                    FROM reviews
                    WHERE slug = $2
                    LIMIT 1
                ), 
                $3, 
                $4,
                $5 
            )
        "#,
        id,
        review_slug.as_ref(),
        review_emotion.emotion as i32,
        review_emotion.position.as_ref(),
        review_emotion.notes.as_ref().map(|n| n.as_ref()),
    )
    .execute(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(StoredReviewEmotion::from(review_emotion))
}

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
