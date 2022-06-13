use sqlx::{types::Uuid, PgPool, QueryBuilder};
use strum::EnumProperty;

use crate::api::reviews::ReviewSlug;

use super::model::{
    Emotion, EmotionPosition, NewReviewEmotion, StoredEmotion, StoredReviewEmotion,
    UpdateReviewEmotion,
};

#[tracing::instrument(
    name = "Retreive review emotion details from the database", 
    skip( pool),
    fields(
        slug = %slug,
        position = %position
    )
)]
pub async fn read_review_emotion(
    slug: &ReviewSlug,
    position: EmotionPosition,
    pool: &PgPool,
) -> Result<StoredReviewEmotion, sqlx::Error> {
    let review_emotion = sqlx::query_as!(
        StoredReviewEmotion,
        r#"
            SELECT name as emotion,
                   position,
                   notes
              FROM reviews,
                   review_emotions,
                   emotions
            WHERE  reviews.slug   = $1
              AND  review_emotions.position = $2
              AND  review_emotions.emotion_id = emotions.id
        "#,
        slug.as_ref(),
        position.as_ref()
    )
    .fetch_one(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(review_emotion)
}

// TODO update the updated_at date on the review
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
            );
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

#[tracing::instrument(
    name = "Saving updated review emotion details in the database",
    skip(review_emotion, pool),
    fields(
        slug = %slug,
        position = %position
    )
)]
pub async fn update_review_emotion(
    slug: &ReviewSlug,
    review_emotion: &UpdateReviewEmotion,
    position: EmotionPosition,
    pool: &PgPool,
) -> Result<StoredReviewEmotion, sqlx::Error> {
    let emotion = review_emotion.emotion.as_ref().map(|t| *t as i32);
    let update_position = review_emotion.position.as_ref().map(|t| t.as_ref());
    let notes = review_emotion.notes.as_ref().map(|t| t.as_ref());
    let row = sqlx::query!(
        r#"
            UPDATE review_emotions
            SET emotion_id  = COALESCE($1, emotion_id),
                position    = COALESCE($2, position),
                notes       = COALESCE($3, notes)
            WHERE review_id = (SELECT id
                                 FROM reviews
                                WHERE slug = $4
                               )
               AND position = $5
            RETURNING (SELECT name 
                         FROM emotions
                        WHERE id = COALESCE($1, emotion_id)
                      ),
                        position, 
                        notes
        "#,
        emotion,
        update_position,
        notes,
        slug.as_ref(),
        position.as_ref()
    )
    .fetch_one(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;

    let updated_review = StoredReviewEmotion {
        emotion: row.name.unwrap(),
        position: row.position,
        notes: row.notes,
    };
    Ok(updated_review)
}

#[tracing::instrument(
    name = "Deleting review emotion details from the database",
    skip(pool),
    fields(
        slug = %slug,
        position = %position
    )
)]
pub async fn db_delete_review_emotion(
    slug: &ReviewSlug,
    position: EmotionPosition,
    pool: &PgPool,
) -> Result<(), sqlx::Error> {
    let _ = sqlx::query!(
        r#"
            DELETE 
              FROM  review_emotions
             WHERE  review_id = (SELECT id
                                FROM reviews
                                WHERE slug = $1
                               )
                AND position = $2
        "#,
        slug.as_ref(),
        position.as_ref()
    )
    .execute(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(())
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
