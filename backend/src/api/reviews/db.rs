use chrono::Utc;
use sqlx::{types::Uuid, PgPool, Postgres, Transaction};

use crate::api::{
    read_user_by_id,
    review_emotion::read_review_emotions,
    reviews::model::StoredReview,
    shared::Limits,
    stories::{create_or_return_story, read_story_by_id, StoryResponseData},
    users::{model::UserProfileData, NewUsername},
};

use super::model::{CompleteReviewData, NewReview, ReviewQueryOptions, ReviewSlug, UpdateReview};
use futures_lite::{stream, StreamExt};

#[tracing::instrument(
    name = "Retreive review id from the database", 
    skip( pool),
    fields(
        slug = %slug
    )
)]
pub async fn review_id_by_username_and_slug(
    username: &NewUsername,
    slug: &ReviewSlug,
    pool: &PgPool,
) -> Result<Uuid, sqlx::Error> {
    let review = sqlx::query!(
        r#"
        SELECT id
        FROM reviews,
            users
        WHERE slug = $2
            AND users.user_id = reviews.user_id
            AND users.username = $1
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
    Ok(review.id)
}

#[tracing::instrument(
    name = "Retreive review details from the database", 
    skip( pool),
    fields(
        slug = %slug
    )
)]
async fn db_read_review(
    username: &NewUsername,
    slug: &ReviewSlug,
    pool: &PgPool,
) -> Result<StoredReview, sqlx::Error> {
    let review = sqlx::query_as!(
        StoredReview,
        r#"
        SELECT id,
            story_id,
            slug,
            body,
            created_at,
            updated_at,
            reviews.user_id
        FROM reviews,
            users
        WHERE slug = $2
            AND users.user_id = reviews.user_id
            AND users.username = $1
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
    name = "Attach user and story and emotions to stored_review",
    skip( pool),
    fields(
        stored_review = %stored_review.id
    )
)]
pub async fn create_complete_review(
    stored_review: StoredReview,
    pool: &PgPool,
) -> Result<CompleteReviewData, sqlx::Error> {
    let story = read_story_by_id(&stored_review.story_id, pool).await?;
    let user = read_user_by_id(&stored_review.user_id.into(), pool).await?;
    let review_emotions = read_review_emotions(&stored_review.id, pool).await?;

    Ok(CompleteReviewData {
        stored_review,
        story: StoryResponseData::from(story),
        emotions: review_emotions,
        user: UserProfileData::from(user),
    })
}

#[tracing::instrument(
    name = "Read review details and attach user and story and emotions",
    skip( pool),
    fields(
        slug = %slug
    )
)]
pub async fn read_review(
    username: &NewUsername,
    slug: &ReviewSlug,
    pool: &PgPool,
) -> Result<CompleteReviewData, sqlx::Error> {
    let stored_review = db_read_review(username, slug, pool).await?;
    create_complete_review(stored_review, pool).await
}

#[tracing::instrument(
    name = "Retreive review details from the database", 
    skip(pool, query_options),
    fields(
        limit = %format!("{:?}", limits.limit),
        offset = %limits.offset
    )
)]
async fn db_read_reviews(
    query_options: &ReviewQueryOptions,
    limits: &Limits,
    pool: &PgPool,
) -> Result<Vec<StoredReview>, sqlx::Error> {
    let user_id: Option<Uuid> = query_options.user_id.map(|u| u.try_into().unwrap());
    let reviews = sqlx::query_as!(
        StoredReview,
        r#"
        SELECT id,
            story_id,
            slug,
            body,
            created_at,
            updated_at,
            reviews.user_id
        FROM reviews,
            users
        WHERE reviews.user_id = COALESCE($3, reviews.user_id)
            AND reviews.user_id = users.user_id
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
) -> Result<Vec<CompleteReviewData>, sqlx::Error> {
    let stored = db_read_reviews(query_options, limits, pool).await?;

    stream::iter(stored)
        .then(|r| create_complete_review(r, pool))
        .try_collect()
        .await
}

#[tracing::instrument(
    name = "Saving new review details in the database",
    skip(review, story_id, transaction)
)]
async fn db_create_review(
    review: &NewReview,
    story_id: Uuid,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<StoredReview, sqlx::Error> {
    let id = Uuid::new_v4();
    let time = Utc::now();
    let user_id: Uuid = review.user_id.try_into().unwrap();

    let created_review = sqlx::query_as!(
        StoredReview,
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

#[tracing::instrument(
    name = "Saving new review details and attach user and story and emotions",
    skip(review, pool)
)]
pub async fn create_review(
    review: &NewReview,
    pool: &PgPool,
) -> Result<CompleteReviewData, sqlx::Error> {
    let mut transaction = pool.begin().await?;

    let story = create_or_return_story(&review.story, &mut transaction).await?;
    let created_review = db_create_review(review, story.id, &mut transaction).await?;

    transaction.commit().await?;

    let user = read_user_by_id(&created_review.user_id.into(), pool).await?;

    Ok(CompleteReviewData {
        stored_review: created_review,
        emotions: vec![],
        story: StoryResponseData::from(story),
        user: UserProfileData::from(user),
    })
}

#[tracing::instrument(
    name = "Saving updated review details in the database",
    skip(review, transaction),
    fields(
        slug = %slug
    )
)]
async fn db_update_review(
    username: &NewUsername,
    slug: &ReviewSlug,
    review: &UpdateReview,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<StoredReview, sqlx::Error> {
    let body = review.body.as_ref().map(|t| t.as_ref());
    let updated_at = Utc::now();

    let updated_review = sqlx::query_as!(
        StoredReview,
        r#"
        UPDATE reviews
        SET body = COALESCE($1, body),
            updated_at = $2
        WHERE slug = $3
            AND reviews.user_id = (
                SELECT user_id
                FROM users
                WHERE username = $4
            )
        RETURNING id,
            story_id,
            slug,
            body,
            created_at,
            updated_at,
            user_id
        "#,
        body,
        updated_at,
        slug.as_ref(),
        username.as_ref()
    )
    .fetch_one(transaction)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;

    Ok(updated_review)
}

#[tracing::instrument(
    name = "Saving updated review details and attach user and story and emotions",
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
) -> Result<CompleteReviewData, sqlx::Error> {
    let mut transaction = pool.begin().await?;

    match &review.story {
        Some(s) => {
            create_or_return_story(s, &mut transaction).await?;
        }
        None => {},
    };
    let updated_review = db_update_review(username, slug, review, &mut transaction).await?;

    transaction.commit().await?;

    create_complete_review(updated_review, pool).await
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
