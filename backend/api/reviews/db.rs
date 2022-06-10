use chrono::Utc;
use sqlx::{PgPool, Postgres, Transaction};
use uuid::Uuid;

use crate::api::{reviews::model::StoredReview, uuid_to_sqlx_uuid, Limits, UserId};

use super::model::{NewReview, ReviewSlug, UpdateReview};

#[tracing::instrument(
    name = "Retreive review details from the database", 
    skip( pool),
    fields(
        slug = %slug
    )
)]
pub async fn read_review(slug: &ReviewSlug, pool: &PgPool) -> Result<StoredReview, sqlx::Error> {
    let review = sqlx::query_as!(
        StoredReview,
        r#"
            SELECT title, slug, body, created_at, updated_at, user_id
            FROM reviews 
            WHERE slug = $1
        "#,
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
    skip( pool),
    fields(
        limit = %limits.limit,
        offset = %limits.offset
    )
)]
pub async fn read_reviews(
    limits: &Limits,
    pool: &PgPool,
) -> Result<Vec<StoredReview>, sqlx::Error> {
    let reviews = sqlx::query_as!(
        StoredReview,
        r#"
            SELECT title, slug, body, created_at, updated_at, user_id
            FROM reviews 
            ORDER BY updated_at
            LIMIT $1
            OFFSET $2
        "#,
        limits.limit,
        limits.offset
    )
    .fetch_all(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(reviews)
}

#[tracing::instrument(name = "Saving new review details in the database", skip(review, pool))]
pub async fn create_review(review: &NewReview, pool: &PgPool) -> Result<StoredReview, sqlx::Error> {
    let id: sqlx::types::Uuid = sqlx::types::Uuid::from_u128(Uuid::new_v4().as_u128());
    let time = Utc::now();
    let user_id: sqlx::types::Uuid = review.user_id.try_into().unwrap();
    let stored_review = sqlx::query_as!(
        StoredReview,
        r#"
            INSERT INTO reviews (id, title, slug, body, created_at, updated_at, user_id)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            RETURNING title, slug, body, created_at, updated_at, user_id
        "#,
        id,
        review.title.as_ref(),
        review.slug.as_ref(),
        review.body.as_ref(),
        time,
        time,
        user_id
    )
    .fetch_one(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(stored_review)
}

#[tracing::instrument(
    name = "Retreive user_id of review from database.", 
    skip(pool),
    fields(
        slug = %slug
    )
)]
pub async fn read_review_user(slug: &ReviewSlug, pool: &PgPool) -> Result<UserId, sqlx::Error> {
    let row = sqlx::query!(
        r#"
            SELECT user_id
            FROM reviews 
            WHERE slug = $1
        "#,
        slug.as_ref()
    )
    .fetch_one(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(row.user_id.into())
}

#[tracing::instrument(
    name = "Saving updated review details in the database",
    skip(review, pool),
    fields(
        slug = %slug
    )
)]
pub async fn update_review(
    slug: &ReviewSlug,
    review: &UpdateReview,
    pool: &PgPool,
) -> Result<StoredReview, sqlx::Error> {
    let title = review.title.as_ref().map(|t| t.as_ref());
    let update_slug = review.slug.as_ref().map(|t| t.as_ref());
    let body = review.body.as_ref().map(|t| t.as_ref());
    let stored_review = sqlx::query_as!(
        StoredReview,
        r#"
            UPDATE reviews
            SET title      = COALESCE($1, title),
                slug       = COALESCE($2, slug),
                body       = COALESCE($3, body),
                updated_at = $4
            WHERE     slug = $5
            RETURNING title, slug, body, created_at, updated_at, user_id
        "#,
        title,
        update_slug,
        body,
        Utc::now(),
        slug.as_ref()
    )
    .fetch_one(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(stored_review)
}

#[tracing::instrument(
    name = "Deleting review details from the database",
    skip(pool),
    fields(
        slug = %slug
    )
)]
pub async fn delete_review(slug: &ReviewSlug, pool: &PgPool) -> Result<(), sqlx::Error> {
    sqlx::query!(
        r#"
            DELETE FROM reviews
            WHERE     slug = $1
        "#,
        slug.as_ref()
    )
    .execute(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(())
}

#[tracing::instrument(
    name = "Deleting reviews from the database",
    skip(transaction),
    fields(
        user_id = %user_id
    )
)]
pub async fn delete_reviews_by_user_id(
    user_id: &UserId,
    transaction: &mut Transaction<'_, Postgres>,
) -> Result<(), sqlx::Error> {
    let id = uuid_to_sqlx_uuid(user_id);
    sqlx::query!(
        r#"
            DELETE FROM reviews
            WHERE       user_id = $1
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
