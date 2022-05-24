use crate::domain::{NewReview, ReviewSlug, UpdateReview};
use chrono::{DateTime, Utc};
use serde::Serialize;
use sqlx::PgPool;
use uuid::Uuid;

#[derive(Debug, Serialize)]
pub struct StoredReview {
    pub title: String,
    pub review: String,
    created_at: DateTime<Utc>,
}

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
            SELECT title, review, created_at
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
pub async fn create_review(review: &NewReview, pool: &PgPool) -> Result<(), sqlx::Error> {
    sqlx::query!(
        r#"
            INSERT INTO reviews (id, title, slug, review, created_at, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6)
        "#,
        Uuid::new_v4(),
        review.title.as_ref(),
        review.slug.as_ref(),
        review.text.as_ref(),
        Utc::now(),
        Utc::now()
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
) -> Result<String, sqlx::Error> {
    let title = match &review.title {
        Some(t) => Some(t.as_ref()),
        None => None,
    };
    let update_slug = match &review.slug {
        Some(t) => Some(t.as_ref()),
        None => None,
    };
    let text = match &review.text {
        Some(t) => Some(t.as_ref()),
        None => None,
    };
    let new_slug = sqlx::query!(
        r#"
            UPDATE reviews
            SET title      = COALESCE($1, title),
                slug       = COALESCE($2, slug),
                review     = COALESCE($3, review),
                updated_at = $4
            WHERE     slug = $5
            RETURNING slug
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
    })?
    .slug;
    Ok(new_slug)
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
