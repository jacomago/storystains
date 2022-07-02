use sqlx::{Postgres, Transaction};

use super::{db::db_create_story, model::NewStory};

#[tracing::instrument(
    name = "Save new story details in the database",
    skip(story, transaction)
)]
pub async fn create_or_return_story_id(
    story: &NewStory,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<sqlx::types::Uuid, sqlx::Error> {
    let stored = db_create_story(story, transaction).await?;
    Ok(stored.id)
}
