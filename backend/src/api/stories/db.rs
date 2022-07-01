use sqlx::{types::Uuid, PgPool};

use super::model::{NewStory, StoredStory};

#[tracing::instrument(name = "Saving new story details in the database", skip(story, pool))]
pub async fn create_story(story: &NewStory, pool: &PgPool) -> Result<StoredStory, sqlx::Error> {
    let id = Uuid::new_v4();
    let creator_id = Uuid::new_v4();

    let mut transaction = pool.begin().await?;

    let updated_creator = sqlx::query!(
        r#"
        INSERT INTO creators (id, name)
        VALUES ($1, $2) ON CONFLICT DO NOTHING
        RETURNING id
        "#,
        creator_id,
        story.creator.as_ref(),
    )
    .fetch_one(&mut transaction)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;

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
        updated_creator.id,
    )
    .fetch_one(&mut transaction)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;

    transaction.commit().await?;

    Ok(created_story)
}
