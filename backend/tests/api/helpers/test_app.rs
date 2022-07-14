use once_cell::sync::Lazy;
use sqlx::{Connection, PgConnection, PgPool};
use storystains::startup::get_connection_pool;
use storystains::{configuration::get_configuration, startup::Application};
use uuid::Uuid;

use super::db::{configure_database, remove_database};
use super::{TestUser, TRACING};
pub struct TestApp {
    pub address: String,
    pub db_name: String,
    pub db_pool: PgPool,
    pub api_client: reqwest::Client,
    pub test_user: TestUser,
}

impl TestApp {
    // TODO make a wrapper around each test as a macro
    // see test-context crate and https://lik.ai/blog/async-setup-and-teardown-in-rust
    pub async fn teardown(&self) {
        self.db_pool.close().await;
        let config = get_configuration().expect("Failed to read configuration.");
        let mut conn = PgConnection::connect_with(&config.database.without_db())
            .await
            .expect("Failed to connect to db");
        remove_database(&mut conn, &self.db_name).await;
        conn.close().await.expect("Failed to close connection");
    }

    pub async fn spawn_app() -> Self {
        Lazy::force(&TRACING);

        let user = TestUser::generate();

        // Randomise configuration to ensure test isolation
        let db_name = Uuid::new_v4().to_string();
        let configuration = {
            let mut c = get_configuration().expect("Failed to read configuration.");
            // Use a different database for each test case
            c.database.database_name = db_name.to_string();
            c.database.max_connections = 4;
            // Use a random OS port
            c.application.port = 0;
            c.application.exp_token_seconds = user.exp_seconds;
            c
        };

        // Create and migrate the database
        configure_database(&configuration.database).await;

        let application = Application::build(configuration.clone())
            .await
            .expect("Failed to build application.");
        // Get the port before spawning the application
        let address = format!("http://127.0.0.1:{}/api", application.port());
        let _ = tokio::spawn(application.run_until_stopped());

        let api_client = reqwest::Client::builder()
            .redirect(reqwest::redirect::Policy::none())
            .build()
            .unwrap();

        let app = Self {
            address,
            db_pool: get_connection_pool(&configuration.database),
            db_name: db_name.clone(),
            api_client,
            test_user: user,
        };
        app.test_user.store(&app).await;
        app
    }
}
