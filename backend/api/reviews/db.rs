use chrono::Utc;
use sqlx::{types::Uuid, PgPool, Postgres, Transaction};

use crate::api::{read_user_by_id, reviews::model::StoredReview, Limits, UserId};

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
            SELECT title,
                   slug, 
                   body, 
                   created_at, 
                   updated_at, 
                   username
              FROM reviews,
                   users
            WHERE  slug          = $1
              AND  users.user_id = reviews.user_id
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
            SELECT  title, 
                    slug, 
                    body, 
                    created_at, 
                    updated_at, 
                    username
              FROM  reviews, 
                    users
            WHERE   users.user_id = reviews.user_id
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
    let id = Uuid::new_v4();
    let time = Utc::now();
    let user_id: sqlx::types::Uuid = review.user_id.try_into().unwrap();
    let _ = sqlx::query!(
        r#" 
            INSERT INTO reviews (id, title, slug, body, created_at, updated_at, user_id)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
        "#,
        id,
        review.title.as_ref(),
        review.slug.as_ref(),
        review.body.as_ref(),
        time,
        time,
        user_id
    )
    .execute(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    let user = read_user_by_id(&review.user_id, pool).await?;
    Ok(StoredReview::from((review, time, time, user)))
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
    let updated_at = Utc::now();
    let row = sqlx::query!(
        r#"
            UPDATE reviews
            SET title      = COALESCE($1, title),
                slug       = COALESCE($2, slug),
                body       = COALESCE($3, body),
                updated_at = $4
            WHERE     slug = $5
            RETURNING title, slug, body, created_at, user_id
        "#,
        title,
        update_slug,
        body,
        updated_at,
        slug.as_ref()
    )
    .fetch_one(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;

    let user = read_user_by_id(&row.user_id.into(), pool).await?;
    let updated_review = StoredReview {
        body: row.body,
        title: row.title,
        slug: row.slug,
        created_at: row.created_at,
        updated_at,
        username: user.username,
    };
    Ok(updated_review)
}

#[tracing::instrument(
    name = "Deleting review details from the database",
    skip(pool),
    fields(
        slug = %slug
    )
)]
pub async fn delete_review(slug: &ReviewSlug, pool: &PgPool) -> Result<(), sqlx::Error> {
    let _ = sqlx::query!(
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
    let id = Uuid::from(*user_id);
    let _ = sqlx::query!(
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
