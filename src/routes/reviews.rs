use actix_web::{web, HttpResponse};
use chrono::Utc;
use sqlx::PgPool;
use uuid::Uuid;

use crate::domain::{NewReview, ReviewReview, ReviewTitle};

#[derive(serde::Deserialize)]
pub struct FormData {
    title: String,
    review: String,
}

impl TryFrom<FormData> for NewReview {
    type Error = String;
    fn try_from(value: FormData) -> Result<Self, Self::Error> {
        let title = ReviewTitle::parse(value.title)?;
        let review = ReviewReview::parse(value.review)?;
        Ok(Self { title, review })
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
pub async fn review(form: web::Form<FormData>, pool: web::Data<PgPool>) -> HttpResponse {
    let new_review = match form.0.try_into() {
        Ok(form) => form,
        Err(_) => return HttpResponse::BadRequest().finish(),
    };
    match create_review(&new_review, pool).await {
        Ok(_) => HttpResponse::Ok().finish(),
        Err(_) => HttpResponse::InternalServerError().finish(),
    }
}

#[tracing::instrument(name = "Saving new review details in the database", skip(review, pool))]
pub async fn create_review(review: &NewReview, pool: web::Data<PgPool>) -> Result<(), sqlx::Error> {
    sqlx::query!(
        r#"
            INSERT INTO reviews (id, title, review, created_at)
            VALUES ($1, $2, $3, $4)
        "#,
        Uuid::new_v4(),
        review.title.as_ref(),
        review.review.as_ref(),
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
