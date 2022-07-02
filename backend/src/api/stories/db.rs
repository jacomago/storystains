use sqlx::{types::Uuid, PgPool, Postgres, Transaction};

use crate::api::shared::{short_form_text::ShortFormText, Limits};

use super::model::{NewStory, StoredStory};

#[tracing::instrument(
    name = "Saving new creator details in the database",
    skip(creator, transaction)
)]
pub async fn create_or_update_creator(
    creator: &ShortFormText,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<Uuid, sqlx::Error> {
    let creator_id = Uuid::new_v4();
    let updated_creator = sqlx::query!(
        r#"
        INSERT INTO creators (id, name)
        VALUES ($1, $2) ON CONFLICT DO NOTHING
        RETURNING id
        "#,
        creator_id,
        creator.as_ref(),
    )
    .fetch_one(transaction)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(updated_creator.id)
}

#[tracing::instrument(name = "Saving new story details in the database", skip(story, pool))]
pub async fn create_story(story: &NewStory, pool: &PgPool) -> Result<StoredStory, sqlx::Error> {
    let mut transaction = pool.begin().await?;
    let created_story = db_create_story(story, &mut transaction).await?;
    transaction.commit().await?;
    Ok(created_story)
}

#[tracing::instrument(
    name = "Saving new story details in the database",
    skip(story, transaction)
)]
pub async fn db_create_story(
    story: &NewStory,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<StoredStory, sqlx::Error> {
    let id = Uuid::new_v4();

    let creator_id = create_or_update_creator(&story.creator, transaction).await?;

    // TODO should be able to use joins and not the inner queries
    // see https://github.com/launchbadge/sqlx/issues/1126
    let created_story = sqlx::query_as!(
        StoredStory,
        r#" 
        INSERT INTO stories (id, title, medium_id, creator_id)
        VALUES (
                $1,
                $2,
                (
                    SELECT id
                    FROM mediums
                    WHERE name = $3
                    LIMIT 1
                ), $4
            )
        RETURNING id,
            title,
            (
                SELECT name
                FROM mediums
                WHERE id = medium_id
                LIMIT 1
            ) as medium,
            (
                SELECT name
                FROM creators
                WHERE id = creator_id
                LIMIT 1
            ) as creator
        "#,
        id,
        story.title.as_ref(),
        story.medium.as_ref(),
        creator_id,
    )
    .fetch_one(transaction)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;

    Ok(created_story)
}

#[tracing::instrument(
    name = "Retreive story details from the database", 
    skip(pool),
    fields(
        limit = %format!("{:?}", limits.limit),
        offset = %limits.offset
    )
)]
pub async fn read_stories(limits: &Limits, pool: &PgPool) -> Result<Vec<StoredStory>, sqlx::Error> {
    // TODO Should be able to do a triple join
    // seems like could be a bug https://github.com/launchbadge/sqlx/issues/1852
    let stories = sqlx::query_as!(
        StoredStory,
        r#"
        with story_mediums as (
            SELECT 
                stories.id as id,
                stories.title as title,
                mediums.name as medium,
                stories.creator_id as creator_id
            FROM stories
                JOIN mediums ON stories.medium_id = mediums.id
            )
        SELECT
            story_mediums.id as "id!",
            story_mediums.title as "title!",
            story_mediums.medium,
            creators.name as creator
        FROM story_mediums
            JOIN creators ON story_mediums.creator_id = creators.id
        "#,
    )
    .fetch_all(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(stories)
}
