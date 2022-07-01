use sqlx::{types::Uuid, PgPool};

use super::model::{NewStory, StoredStory};

#[tracing::instrument(name = "Saving new story details in the database", skip(story, pool))]
pub async fn create_story(story: &NewStory, pool: &PgPool) -> Result<StoredStory, sqlx::Error> {
    let id = Uuid::new_v4();
    let creator_id = Uuid::new_v4();
    let created_story = sqlx::query_as!(
        StoredStory,
        r#" 
        WITH creator as (
            INSERT INTO creators (id, name)
            VALUES ($4, $5) ON CONFLICT DO NOTHING
            RETURNING (
                    SELECT id
                    FROM creators
                    WHERE name = $5
                    LIMIT 1
                ) as id
        )
        INSERT INTO stories (id, title, medium_id, creator_id)
        VALUES (
                $1,
                $2,
                (
                    SELECT id
                    FROM mediums
                    WHERE name = $3
                    LIMIT 1
                ), (
                    SELECT id
                    FROM creator
                    LIMIT 1
                )
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
        story.creator.as_ref(),
    )
    .fetch_one(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(created_story)
}
