use sqlx::PgPool;

use crate::api::mediums::model::StoredMedium;

#[tracing::instrument(name = "Get all mediums from the db", skip(pool))]
pub async fn retreive_all_mediums(pool: &PgPool) -> Result<Vec<StoredMedium>, sqlx::Error> {
    let stored = sqlx::query_as!(
        StoredMedium,
        r#"
            SELECT id, name
            FROM mediums
        "#
    )
    .fetch_all(pool)
    .await
    .map_err(|e| {
        tracing::error!("Failed to execute query: {:?}", e);
        e
    })?;
    Ok(stored)
}
