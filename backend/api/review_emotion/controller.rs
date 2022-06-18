use futures_lite::{stream, StreamExt};
use sqlx::{types::Uuid, PgPool, Postgres, Transaction};
use std::iter::zip;

use crate::api::emotions::read_emotion_by_id_pool;

use super::{
    db::{self, db_delete_review_emotions_by_review, db_delete_review_emotions_by_user_id},
    ReviewEmotionData,
};

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

    Ok(zip(stored, emotions).map(ReviewEmotionData::from).collect())
}

#[tracing::instrument(
    name = "Deleting review emotion details by review id",
    skip(transaction),
    fields(
        review_id = %review_id,
    )
)]
pub async fn delete_review_emotions_by_review(
    review_id: &Uuid,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<(), sqlx::Error> {
    db_delete_review_emotions_by_review(review_id, transaction).await?;
    Ok(())
}

#[tracing::instrument(
    name = "Deleting review emotion details by user id",
    skip(transaction, user_id),
    fields()
)]
pub async fn delete_review_emotions_by_user_id(
    user_id: &Uuid,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<(), sqlx::Error> {
    db_delete_review_emotions_by_user_id(user_id, transaction).await?;
    Ok(())
}
