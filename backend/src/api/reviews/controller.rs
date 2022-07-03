use sqlx::{types::Uuid, Postgres, Transaction};

use crate::api::{review_emotion::delete_review_emotions_by_user_id, UserId};

use super::db::db_delete_reviews_by_user_id;

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
