use futures_lite::{stream, StreamExt};
use sqlx::{types::Uuid, PgPool};
use std::iter::zip;

use crate::api::emotions::{read_emotion_by_id_pool, StoredEmotion};

use super::{db, ReviewEmotionData, StoredReviewEmotion};

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
) -> Result<Vec<ReviewEmotionData>, sqlx::Error> {
    let stored = db::read_review_emotions(review_id, pool).await?;

    let ids: Vec<i32> = stored.iter().map(|s| s.emotion_id).collect();
    let stream_stored: Result<Vec<_>, sqlx::Error> = stream::iter(ids)
        .then(|r| read_emotion_by_id_pool(r, pool))
        .try_collect()
        .await;

    let emotions = stream_stored?;
    let all: Vec<(StoredReviewEmotion, StoredEmotion)> = zip(stored, emotions).collect();
    Ok(all.into_iter().map(ReviewEmotionData::from).collect())
}
