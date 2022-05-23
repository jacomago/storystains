use actix_web::{web, HttpResponse};
use chrono::{DateTime, Utc};
use serde::Serialize;
use sqlx::PgPool;
use uuid::Uuid;

use crate::domain::{NewReview, ReviewText, ReviewTitle};

use super::see_other;

#[derive(serde::Deserialize)]
pub struct FormData {
    title: String,
    review: String,
}

impl TryFrom<FormData> for NewReview {
    type Error = String;
    fn try_from(value: FormData) -> Result<Self, Self::Error> {
        let title = ReviewTitle::parse(value.title)?;
        let text = ReviewText::parse(value.review)?;
        Ok(Self { title, text })
    }
}

#[tracing::instrument(
    name = "Adding a new review",
    skip(form, pool),
    fields(
        reviews_title = %form.title,
        reviews_review = %form.review
    )
)]
pub async fn post_review(form: web::Form<FormData>, pool: web::Data<PgPool>) -> HttpResponse {
    let new_review = match form.0.try_into() {
        Ok(form) => form,
        Err(_) => return HttpResponse::BadRequest().finish(),
    };
    match create_review(&new_review, pool).await {
        Ok(_) => see_other(format!("/reviews/{}", new_review.title.slug()).as_str()),
        Err(_) => HttpResponse::InternalServerError().finish(),
    }
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
        review.title.slug(),
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

#[tracing::instrument(
    name = "Getting a review",
    skip(pool),
    fields(
        title = %title,
    )
)]
pub async fn get_review(title: web::Path<String>, pool: web::Data<PgPool>) -> HttpResponse {
    let review_title = match ReviewTitle::parse(title.to_string()) {
        Ok(t) => t,
        Err(_) => return HttpResponse::BadRequest().finish(),
    };
    let stored_review = match read_review(&review_title.slug(), pool).await {
        Ok(s) => s,
        Err(_) => return HttpResponse::InternalServerError().finish(),
    };

    HttpResponse::Ok().json(stored_review)
}

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
    slug: &str,
    pool: web::Data<PgPool>,
) -> Result<StoredReview, sqlx::Error> {
    let review = sqlx::query_as!(
        StoredReview,
        r#"
            SELECT title, review, created_at
            FROM reviews 
            WHERE slug = $1
        "#,
        slug
    )
    .fetch_one(pool.get_ref())
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(review)
}
