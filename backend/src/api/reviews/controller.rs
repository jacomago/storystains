use sqlx::{types::Uuid, PgPool, Postgres, Transaction};

use crate::api::{review_emotion::delete_review_emotions_by_user_id, shared::Limits, UserId};

use super::{
    db::{db_delete_reviews_by_user_id, read_reviews},
    model::ReviewQueryOptions,
};

#[tracing::instrument(name = "Read review ids", skip(pool, limits, query_options), fields())]
pub async fn get_review_ids(
    query_options: &ReviewQueryOptions,
    limits: Limits,
    pool: &PgPool,
) -> Result<Vec<sqlx::types::Uuid>, sqlx::Error> {
    let stored = read_reviews(query_options, &limits, pool).await?;
    let ids: Vec<sqlx::types::Uuid> = stored.iter().map(|s| s.id).collect();
    Ok(ids)
}

#[tracing::instrument(
    name = "Deleting reviews by user id",
    skip(transaction),
    fields(
        user_id = %user_id
    )
)]
pub async fn delete_reviews_by_user_id(
    user_id: &UserId,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<(), sqlx::Error> {
    let id = Uuid::from(*user_id);
    delete_review_emotions_by_user_id(&id, transaction).await?;
    db_delete_reviews_by_user_id(&id, transaction).await?;
    Ok(())
}
