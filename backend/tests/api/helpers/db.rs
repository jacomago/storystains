use sqlx::{Connection, Executor, PgConnection, PgPool};
use storystains::configuration::DatabaseSettings;

pub async fn configure_database(config: &DatabaseSettings) {
    // Create database
    let mut connection = PgConnection::connect_with(&config.without_db())
        .await
        .expect("Failed to connect to Postgres");
    connection
        .execute(format!(r#"CREATE DATABASE "{}";"#, config.database_name).as_str())
        .await
        .expect("Failed to create database.");
    connection.close();
    // Migrate database
    let connection_pool = PgPool::connect_with(config.with_db())
        .await
        .expect("Failed to connect to Postgres.");
    sqlx::migrate!("./migrations")
        .run(&connection_pool)
        .await
        .expect("Failed to migrate the database");
    connection_pool.close().await;
}

pub async fn remove_database(conn: &mut PgConnection, db_name: &str) {
    conn.execute(&*format!("DROP DATABASE \"{}\" WITH (FORCE)", db_name))
        .await
        .expect("Failed to remove db");
}
