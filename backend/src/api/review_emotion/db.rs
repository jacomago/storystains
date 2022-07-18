use sqlx::{types::Uuid, PgPool, Postgres, Transaction};

use crate::api::{reviews::ReviewSlug, users::NewUsername};

use super::model::{EmotionPosition, NewReviewEmotion, StoredReviewEmotion, UpdateReviewEmotion};

#[tracing::instrument(
    name = "Retreive review's emotion details from the database", 
    skip( pool),
    fields(
        review_jid = %review_id,
    )
)]
pub async fn read_review_emotions(
    review_id: &Uuid,
    pool: &PgPool,
) -> Result<Vec<StoredReviewEmotion>, sqlx::Error> {
    let review_emotions = sqlx::query_as!(
        StoredReviewEmotion,
        r#"
            SELECT emotion_id,
                   position,
                   notes
              FROM review_emotions
            WHERE  review_id = $1
          ORDER BY position ASC
        "#,
        review_id,
    )
    .fetch_all(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(review_emotions)
}

#[tracing::instrument(
    name = "Retreive review emotion details from the database", 
    skip( pool),
    fields(
        slug = %slug,
        position = %position
    )
)]
pub async fn read_review_emotion(
    username: &NewUsername,
    slug: &ReviewSlug,
    position: EmotionPosition,
    pool: &PgPool,
) -> Result<StoredReviewEmotion, sqlx::Error> {
    let review_emotion = sqlx::query_as!(
        StoredReviewEmotion,
        r#"
            SELECT emotion_id,
                   position,
                   notes
              FROM users, 
                   reviews,
                   review_emotions,
                   emotions
            WHERE  users.user_id  = reviews.user_id
              AND  users.username = $1
              AND  reviews.slug   = $2
              AND  review_emotions.position = $3
        "#,
        username.as_ref(),
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
    skip(review_emotion, transaction)
)]
pub async fn create_review_emotion(
    username: &NewUsername,
    review_slug: &ReviewSlug,
    review_emotion: &NewReviewEmotion,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<StoredReviewEmotion, sqlx::Error> {
    let id = Uuid::new_v4();
    let stored = sqlx::query_as!(
        StoredReviewEmotion,
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
                      FROM users,
                           reviews
                     WHERE slug           = $3
                       AND users.user_id  = reviews.user_id
                       AND users.username = $2
                     LIMIT 1
                ), 
                (
                    SELECT id
                      FROM emotions
                     WHERE name           = $4
                     LIMIT 1
                ),
                $5,
                $6 
            )
            RETURNING emotion_id, position, notes
        "#,
        id,
        username.as_ref(),
        review_slug.as_ref(),
        review_emotion.emotion.as_ref(),
        review_emotion.position.as_ref(),
        review_emotion.notes.as_ref().map(|n| n.as_ref()),
    )
    .fetch_one(transaction)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;

    Ok(stored)
}

#[tracing::instrument(
    name = "Saving updated review emotion details in the database",
    skip(review_emotion, transaction),
    fields(
        slug = %slug,
        position = %position
    )
)]
pub async fn update_review_emotion(
    username: &NewUsername,
    slug: &ReviewSlug,
    review_emotion: &UpdateReviewEmotion,
    position: EmotionPosition,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<StoredReviewEmotion, sqlx::Error> {
    let emotion = review_emotion.emotion.as_ref().map(|t| t.as_ref());
    let update_position = review_emotion.position.as_ref().map(|t| t.as_ref());
    let notes = review_emotion.notes.as_ref().map(|t| t.as_ref());
    let stored = sqlx::query_as!(
        StoredReviewEmotion,
        r#"
            UPDATE review_emotions
            SET emotion_id  = COALESCE((
                                    SELECT id
                                    FROM emotions
                                    WHERE name = $1
                                    LIMIT 1
                                ), emotion_id),
                position    = COALESCE($2, position),
                notes       = COALESCE($3, notes)
            WHERE review_id = (SELECT id
                                 FROM users,
                                      reviews
                                WHERE slug           = $4
                                  AND users.user_id  = reviews.user_id
                                  AND users.username = $6
                                LIMIT 1
                               )
               AND position = $5
            RETURNING emotion_id,
                      position, 
                      notes
        "#,
        emotion,
        update_position,
        notes,
        slug.as_ref(),
        position.as_ref(),
        username.as_ref()
    )
    .fetch_one(transaction)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;

    Ok(stored)
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
    username: &NewUsername,
    slug: &ReviewSlug,
    position: EmotionPosition,
    pool: &PgPool,
) -> Result<(), sqlx::Error> {
    let _ = sqlx::query!(
        r#"
            DELETE 
              FROM  review_emotions
             WHERE  review_id = (SELECT id
                                   FROM users,
                                        reviews
                                  WHERE slug           = $1
                                    AND users.user_id  = reviews.user_id
                                    AND users.username = $3
                                  LIMIT 1
                               )
                AND position = $2
        "#,
        slug.as_ref(),
        position.as_ref(),
        username.as_ref()
    )
    .execute(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(())
}

#[tracing::instrument(
    name = "Deleting review emotion details by review id from db",
    skip(transaction),
    fields(
        review_id = %review_id,
    )
)]
pub async fn db_delete_review_emotions_by_review(
    review_id: &Uuid,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<(), sqlx::Error> {
    let _ = sqlx::query!(
        r#"
            DELETE 
              FROM  review_emotions
             WHERE  review_id = $1
        "#,
        review_id,
    )
    .execute(transaction)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(())
}

#[tracing::instrument(
    name = "Deleting review emotion details by user id from db",
    skip(transaction, user_id),
    fields()
)]
pub async fn db_delete_review_emotions_by_user_id(
    user_id: &Uuid,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<(), sqlx::Error> {
    let _ = sqlx::query!(
        r#"
            DELETE 
              FROM  review_emotions re
             WHERE  EXISTS (
                SELECT 1
                  FROM reviews
                 WHERE reviews.id      = re.review_id
                   AND reviews.user_id = $1
             )
        "#,
        user_id,
    )
    .execute(transaction)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(())
}
