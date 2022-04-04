use actix_web::{web, HttpResponse};
use chrono::Utc;
use sqlx::PgPool;
use uuid::Uuid;

#[derive(serde::Deserialize)]
pub struct FormData {
    title: String,
    review: String,
}

#[tracing::instrument(
    name = "Adding a new review",
    skip(form, pool),
    fields(
        reviews_email = %form.title,
        reviews_review = %form.review
    )
)]
pub async fn review(form: web::Form<FormData>, pool: web::Data<PgPool>) -> HttpResponse {
    match create_review(form, pool).await {
        Ok(_) => HttpResponse::Ok().finish(),
        Err(_) => HttpResponse::InternalServerError().finish(),
    }
}

#[tracing::instrument(name = "Saving new review details in the database", skip(form, pool))]
pub async fn create_review(
    form: web::Form<FormData>,
    pool: web::Data<PgPool>,
) -> Result<(), sqlx::Error> {
    sqlx::query!(
        r#"
    INSERT INTO reviews (id, title, review, created_at)
    VALUES ($1, $2, $3, $4)
    "#,
        Uuid::new_v4(),
        form.title,
        form.review,
        Utc::now()
    )
    // We use `get_ref` to get an immutable reference to the `PgConnection`
    // wrapped by `web::Data`.
    .execute(pool.get_ref())
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(())
}
