use actix_web::{web, HttpResponse};
use chrono::Utc;
use sqlx::PgPool;
use uuid::Uuid;

#[derive(serde::Deserialize)]
pub struct FormData {
    title: String,
    review: String,
}

pub async fn review(_form: web::Form<FormData>) -> HttpResponse {
    HttpResponse::Ok().finish()
}

pub async fn create_review(form: web::Form<FormData>, pool: web::Data<PgPool>) -> HttpResponse {
    match sqlx::query!(
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
    {
        Ok(_) => HttpResponse::Ok().finish(),
        Err(e) => {
            println!("Failed to execute query: {}", e);
            HttpResponse::InternalServerError().finish()
        }
    }
}
