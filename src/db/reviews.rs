use crate::domain::{NewReview, ReviewSlug};
use actix_web::web;
use chrono::{DateTime, Utc};
use serde::Serialize;
use sqlx::PgPool;
use uuid::Uuid;

#[derive(Debug, Serialize)]
pub struct StoredReview {
    title: String,
    review: String,
    created_at: DateTime<Utc>,
}

#[tracing::instrument(
    name = "Retreive review details from the database", 
    skip( pool),
    fields(
        slug = %slug
    )
)]
pub async fn read_review(
    slug: &ReviewSlug,
    pool: web::Data<PgPool>,
) -> Result<StoredReview, sqlx::Error> {
    let review = sqlx::query_as!(
        StoredReview,
        r#"
            SELECT title, review, created_at
            FROM reviews 
            WHERE slug = $1
        "#,
        slug.as_ref()
    )
    .fetch_one(pool.get_ref())
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(review)
}

#[tracing::instrument(name = "Saving new review details in the database", skip(review, pool))]
pub async fn create_review(review: &NewReview, pool: web::Data<PgPool>) -> Result<(), sqlx::Error> {
    sqlx::query!(
        r#"
            INSERT INTO reviews (id, title, slug, review, created_at)
            VALUES ($1, $2, $3, $4, $5)
        "#,
        Uuid::new_v4(),
        review.title.as_ref(),
        review.slug.as_ref(),
        review.text.as_ref(),
        Utc::now()
    )
    .execute(pool.get_ref())
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(())
}
