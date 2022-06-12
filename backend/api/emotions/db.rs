use sqlx::{types::Uuid, PgPool};

use crate::api::reviews::ReviewSlug;

use super::model::{NewReviewEmotion, StoredReviewEmotion};

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
            INSERT INTO review_emotions (
                id,
                review_id,
                emotion_id,
                position,
                notes
            )
            SELECT ($1,
                    id,
                    $3,
                    $4,
                    $5
                )
            FROM reviews
            WHERE slug = $2
        "#,
        id,
        review_slug.as_ref(),
        review_emotion.emotion.as_ref(),
        review_emotion.position.as_ref(),
        review_emotion.notes.as_ref(),
    )
    .execute(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(StoredReviewEmotion::from(review_emotion))
}
