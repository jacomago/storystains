use chrono::{DateTime, Utc};
use sqlx::{types::Uuid, PgPool, Postgres, Transaction};

use crate::api::{
    read_user_by_id,
    reviews::model::StoredReview,
    shared::Limits,
    stories::create_or_return_story_id,
    users::{model::StoredUser, NewUsername},
};

use super::model::{NewReview, ReviewQueryOptions, ReviewSlug, UpdateReview};

#[derive(Debug)]
pub struct DBReview {
    pub id: sqlx::types::Uuid,
    pub story_id: sqlx::types::Uuid,
    pub slug: String,
    pub body: String,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub user_id: sqlx::types::Uuid,
}

impl From<(DBReview, StoredUser, &str)> for StoredReview {
    fn from((review, user, title): (DBReview, StoredUser, &str)) -> Self {
        Self {
            id: review.id,
            title: title.to_string(),
            slug: review.slug,
            body: review.body,
            created_at: review.created_at,
            updated_at: review.updated_at,
            username: user.username,
        }
    }
}

#[tracing::instrument(
    name = "Retreive review details from the database", 
    skip( pool),
    fields(
        slug = %slug
    )
)]
pub async fn read_review(
    username: &NewUsername,
    slug: &ReviewSlug,
    pool: &PgPool,
) -> Result<StoredReview, sqlx::Error> {
    let review = sqlx::query_as!(
        StoredReview,
        r#"
        SELECT reviews.id as id,
            title,
            slug,
            body,
            created_at,
            updated_at,
            username
        FROM reviews,
            users,
            stories
        WHERE slug = $2
            AND users.user_id = reviews.user_id
            AND users.username = $1
            AND stories.id = reviews.story_id
        "#,
        username.as_ref(),
        slug.as_ref()
    )
    .fetch_one(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(review)
}

#[tracing::instrument(
    name = "Retreive review details from the database", 
    skip(pool, query_options),
    fields(
        limit = %format!("{:?}", limits.limit),
        offset = %limits.offset
    )
)]
pub async fn read_reviews(
    query_options: &ReviewQueryOptions,
    limits: &Limits,
    pool: &PgPool,
) -> Result<Vec<StoredReview>, sqlx::Error> {
    let user_id: Option<Uuid> = query_options.user_id.map(|u| u.try_into().unwrap());
    let reviews = sqlx::query_as!(
        StoredReview,
        r#"
        SELECT reviews.id as id,
            title,
            slug,
            body,
            created_at,
            updated_at,
            username
        FROM reviews,
            users,
            stories
        WHERE reviews.user_id = COALESCE($3, reviews.user_id)
            AND reviews.user_id = users.user_id
            AND stories.id = reviews.story_id
        ORDER BY updated_at DESC
        LIMIT $1 OFFSET $2
        "#,
        limits.limit,
        limits.offset,
        user_id
    )
    .fetch_all(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(reviews)
}

#[tracing::instrument(
    name = "Saving new review details in the database",
    skip(review, story_id, transaction)
)]
pub async fn db_create_review(
    review: &NewReview,
    story_id: Uuid,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<DBReview, sqlx::Error> {
    let id = Uuid::new_v4();
    let time = Utc::now();
    let user_id: Uuid = review.user_id.try_into().unwrap();

    let created_review = sqlx::query_as!(
        DBReview,
        r#" 
        INSERT INTO reviews (
                id,
                story_id,
                slug,
                body,
                created_at,
                updated_at,
                user_id
            )
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING id,
            story_id,
            slug,
            body,
            created_at,
            updated_at,
            user_id
        "#,
        id,
        story_id,
        review.slug.as_ref(),
        review.body.as_ref(),
        time,
        time,
        user_id,
    )
    .fetch_one(transaction)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;

    Ok(created_review)
}

#[tracing::instrument(name = "Saving new review details in the database", skip(review, pool))]
pub async fn create_review(review: &NewReview, pool: &PgPool) -> Result<StoredReview, sqlx::Error> {
    let mut transaction = pool.begin().await?;
    let story_id = create_or_return_story_id(&review.story, &mut transaction).await?;
    let created_review = db_create_review(review, story_id, &mut transaction).await?;
    transaction.commit().await?;

    let user = read_user_by_id(&review.user_id, pool).await?;
    Ok(StoredReview::from((
        created_review,
        user,
        review.story.title.as_ref(),
    )))
}

#[tracing::instrument(
    name = "Saving updated review details in the database",
    skip(review, pool),
    fields(
        slug = %slug
    )
)]
pub async fn update_review(
    username: &NewUsername,
    slug: &ReviewSlug,
    review: &UpdateReview,
    pool: &PgPool,
) -> Result<StoredReview, sqlx::Error> {
    let title = review.title.as_ref().map(|t| t.as_ref());
    let update_slug = review.slug.as_ref().map(|t| t.as_ref());
    let body = review.body.as_ref().map(|t| t.as_ref());
    let updated_at = Utc::now();

    let mut transaction = pool.begin().await?;

    let updated_story = match title {
        Some(t) => {
            let id = Uuid::new_v4();
            let updated_story = sqlx::query!(
                r#"
                INSERT INTO stories (id, title, medium_id, creator_id)
                VALUES (
                        $1,
                        $2,
                        (
                            SELECT id
                            FROM mediums
                            WHERE name = 'Book'
                        ),
                        (
                            SELECT id
                            FROM creators
                            WHERE name = 'Anonymous'
                        )
                    ) ON CONFLICT DO NOTHING
                RETURNING id, title
                "#,
                id,
                t,
            )
            .fetch_one(&mut transaction)
            .await
            .map_err(|e| {
                tracing::error!("Failed to execute query: {:?}", e);
                e
            })?;
            Some(updated_story)
        }
        None => None,
    };

    let updated_review = sqlx::query!(
        r#"
        UPDATE reviews
        SET story_id = COALESCE($1, story_id),
            slug = COALESCE($2, slug),
            body = COALESCE($3, body),
            updated_at = $4
        WHERE slug = $5
            AND reviews.user_id = (
                SELECT user_id
                FROM users
                WHERE username = $6
            )
        RETURNING id,
            (
                SELECT title
                FROM stories
                WHERE stories.id = story_id
            ) as title,
            story_id,
            slug,
            body,
            created_at,
            updated_at,
            user_id
        "#,
        updated_story.map(|o| o.id),
        update_slug,
        body,
        updated_at,
        slug.as_ref(),
        username.as_ref()
    )
    .fetch_one(&mut transaction)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;

    transaction.commit().await?;

    let user = read_user_by_id(&updated_review.user_id.into(), pool).await?;

    Ok(StoredReview {
        id: updated_review.id,
        title: updated_review.title.unwrap(),
        slug: updated_review.slug,
        body: updated_review.body,
        created_at: updated_review.created_at,
        updated_at,
        username: user.username,
    })
}

#[tracing::instrument(
    name = "Deleting review details from the database",
    skip(transaction),
    fields(
        id = %id
    )
)]
pub async fn delete_review(
    id: &Uuid,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<(), sqlx::Error> {
    let _ = sqlx::query!(
        r#"
            DELETE FROM reviews
            WHERE id = $1
        "#,
        id
    )
    .execute(transaction)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(())
}

#[tracing::instrument(
    name = "Deleting reviews from the database by user id",
    skip(transaction),
    fields(
        user_id = %user_id
    )
)]
pub async fn db_delete_reviews_by_user_id(
    user_id: &Uuid,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<(), sqlx::Error> {
    let _ = sqlx::query!(
        r#"
            DELETE FROM reviews
            WHERE user_id = $1
        "#,
        user_id
    )
    .execute(transaction)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(())
}
