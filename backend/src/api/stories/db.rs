use sqlx::{types::Uuid, PgPool, Postgres, Transaction};

use crate::api::shared::{short_form_text::ShortFormText, Limits};

use super::model::{NewStory, StoredStory, StoryQuery};

#[tracing::instrument(
    name = "Creating or reading creator details from the database",
    skip(creator, transaction)
)]
pub async fn create_or_update_creator(
    creator: &ShortFormText,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<Uuid, sqlx::Error> {
    let creator_id = Uuid::new_v4();
    let updated_creator = sqlx::query!(
        r#"
        WITH new_creator AS (
            INSERT INTO creators (id, name)
            VALUES ($1, $2) ON CONFLICT (name) DO NOTHING
            RETURNING id
        ), exist_creator AS (
            SELECT id 
            FROM creators
            WHERE name = $2
        )
        SELECT id 
        FROM new_creator
        UNION ALL
        SELECT id
        FROM exist_creator
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
    Ok(updated_creator.id.unwrap())
}

#[tracing::instrument(name = "Saving new story details", skip(story, pool))]
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

    // Only want to insert a new story if the same one doesn't already exist
    let created_story = sqlx::query_as!(
        StoredStory,
        r#" 
        WITH new_story AS (
            INSERT INTO stories (id, title, medium_id, creator_id)
            VALUES (
                    $1,
                    $2,
                    (
                        SELECT id
                        FROM mediums
                        WHERE name = $3
                        LIMIT 1
                    ), 
                    $4
                ) ON CONFLICT (title, medium_id, creator_id) DO NOTHING
            RETURNING id,
                title,
                $3 as medium,
                (
                    SELECT name FROM creators WHERE id = $4
                ) as creator
        ), old_story AS (
            SELECT 
                stories.id,
                stories.title as title,
                mediums.name as medium,
                creators.name as creator
            FROM 
                stories,
                creators,
                mediums
            WHERE creators.id = $4
                AND stories.medium_id = mediums.id
                AND mediums.name = $3
                AND stories.title = $2
        ), all_story AS (
        SELECT
            id,
            title,
            medium,
            creator
        FROM old_story
        UNION ALL
        SELECT
            id,
            title,
            medium,
            creator
        FROM new_story
        )
        SELECT 
            id as "id!",
            title as "title!",
            medium as "medium!",
            creator as "creator!"
        FROM all_story
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
    name = "Retreive a single story details from the database by id",
    skip(story_id, pool),
    fields()
)]
pub async fn db_read_story_by_id(
    story_id: &Uuid,
    pool: &PgPool,
) -> Result<StoredStory, sqlx::Error> {
    let stored_story = sqlx::query_as!(
        StoredStory,
        r#"
        SELECT 
            stories.id,
            stories.title as "title!",
            mediums.name as "medium!",
            creators.name as "creator!"
        FROM 
            stories,
            creators,
            mediums
        WHERE 
                stories.id = $1
            AND stories.creator_id = creators.id
            AND stories.medium_id = mediums.id
        "#,
        story_id,
    )
    .fetch_one(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(stored_story)
}

#[tracing::instrument(
    name = "Retreive stories from the database", 
    skip(pool, query),
    fields(
        title = %format!("{:?}", query.options.title),
        medium = %format!("{:?}", query.options.medium),
        creator = %format!("{:?}", query.options.creator),
        limit = %format!("{:?}", query.limit),
        offset = %format!("{:?}", query.offset)
    )
)]
pub async fn read_stories(
    query: StoryQuery,
    pool: &PgPool,
) -> Result<Vec<StoredStory>, sqlx::Error> {
    let limits: Limits = query.query_limits().into();
    let stories = sqlx::query_as!(
        StoredStory,
        r#"
        SELECT
            stories.id as "id",
            stories.title as "title",
            mediums.name as "medium",
            creators.name as "creator"
        FROM stories
            JOIN creators ON stories.creator_id = creators.id
            JOIN mediums ON stories.medium_id = mediums.id
        WHERE ($1::text IS NULL OR stories.title % $1)
            AND ($2::text IS NULL OR creators.name % $2)
            AND ($3::text IS NULL OR mediums.name = $3)
        LIMIT $4
        OFFSET $5
        "#,
        query.options.title,
        query.options.creator,
        query.options.medium,
        limits.limit.as_ref(),
        limits.offset
    )
    .fetch_all(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(stories)
}
