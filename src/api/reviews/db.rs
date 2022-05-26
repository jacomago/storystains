use chrono::Utc;

use sqlx::PgPool;
use uuid::Uuid;

use crate::api::reviews::model::StoredReview;

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
            SELECT title, slug, review, created_at, updated_at
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

#[tracing::instrument(name = "Saving new review details in the database", skip(review, pool))]
pub async fn create_review(review: &NewReview, pool: &PgPool) -> Result<StoredReview, sqlx::Error> {
    let id: sqlx::types::Uuid = sqlx::types::Uuid::from_u128(Uuid::new_v4().as_u128());
    let time = Utc::now();
    let stored_review = sqlx::query_as!(
        StoredReview,
        r#"
            INSERT INTO reviews (id, title, slug, review, created_at, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING title, slug, review, created_at, updated_at
        "#,
        id,
        review.title.as_ref(),
        review.slug.as_ref(),
        review.text.as_ref(),
        time,
        time
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
    let text = review.text.as_ref().map(|t| t.as_ref());
    let stored_review = sqlx::query_as!(
        StoredReview,
        r#"
            UPDATE reviews
            SET title      = COALESCE($1, title),
                slug       = COALESCE($2, slug),
                review     = COALESCE($3, review),
                updated_at = $4
            WHERE     slug = $5
            RETURNING title, slug, review, created_at, updated_at
        "#,
        title,
        update_slug,
        text,
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
