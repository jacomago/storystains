use sqlx::PgPool;

use crate::api::emotions::insert_emotions;

/// Updates the db with any changes needed for startup
/// TODO remove this hack
pub async fn update_db(pool: &PgPool) -> Result<(), anyhow::Error> {
    Ok(insert_emotions(pool).await?)
}
