use sqlx::{PgPool, Postgres, Transaction};

use super::{
    db::{db_create_story, db_read_story_by_id},
    model::{NewStory, StoredStory},
};

#[tracing::instrument(name = "Create new or return story details", skip(story, transaction))]
pub async fn create_or_return_story(
    story: &NewStory,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<StoredStory, sqlx::Error> {
    let stored = db_create_story(story, transaction).await?;
    Ok(stored)
}

#[tracing::instrument(name = "Read story details by id", skip(id, pool))]
pub async fn read_story_by_id(
    id: &sqlx::types::Uuid,
    pool: &PgPool,
) -> Result<StoredStory, sqlx::Error> {
    let stored = db_read_story_by_id(id, pool).await?;
    Ok(stored)
}
