use core::time;
use std::thread;

use once_cell::sync::Lazy;
use serde_json::Value;
use sqlx::{Connection, Executor, PgConnection, PgPool};
use storystains::startup::get_connection_pool;
use storystains::telemetry::{get_subscriber, init_subscriber};
use storystains::{
    configuration::{get_configuration, DatabaseSettings},
    startup::Application,
};
use uuid::Uuid;

// Ensure that the `tracing` stack is only initialised once using `once_cell`
static TRACING: Lazy<()> = Lazy::new(|| {
    let default_filter_level = "info".to_string();
    let subscriber_name = "test".to_string();
    // We cannot assign the output of `get_subscriber` to a variable based on the value
    // of `TEST_LOG` because the sink is part of the type returned by `get_subscriber`,
    // therefore they are not the same type. We could work around it, but this is the
    // most straight-forward way of moving forward.
    if std::env::var("TEST_LOG").is_ok() {
        let subscriber = get_subscriber(subscriber_name, default_filter_level, std::io::stdout);
        init_subscriber(subscriber);
    } else {
        let subscriber = get_subscriber(subscriber_name, default_filter_level, std::io::sink);
        init_subscriber(subscriber);
    };
});

pub struct TestApp {
    pub address: String,
    pub db_pool: PgPool,
    pub api_client: reqwest::Client,
    pub test_user: TestUser,
}

async fn configure_database(config: &DatabaseSettings) -> PgPool {
    // Create database
    let mut connection = PgConnection::connect_with(&config.without_db())
        .await
        .expect("Failed to connect to Postgres");
    connection
        .execute(format!(r#"CREATE DATABASE "{}";"#, config.database_name).as_str())
        .await
        .expect("Failed to create database.");
    // Migrate database
    let connection_pool = PgPool::connect_with(config.with_db())
        .await
        .expect("Failed to connect to Postgres.");
    sqlx::migrate!("./migrations")
        .run(&connection_pool)
        .await
        .expect("Failed to migrate the database");
    connection_pool
}

pub async fn spawn_app() -> TestApp {
    Lazy::force(&TRACING);

    let user = TestUser::generate();
    // Randomise configuration to ensure test isolation
    let configuration = {
        let mut c = get_configuration().expect("Failed to read configuration.");
        // Use a different database for each test case
        c.database.database_name = Uuid::new_v4().to_string();
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
    let address = format!("http://127.0.0.1:{}", application.port());
    let _ = tokio::spawn(application.run_until_stopped());

    let api_client = reqwest::Client::builder()
        .redirect(reqwest::redirect::Policy::none())
        .build()
        .unwrap();

    let app = TestApp {
        address,
        db_pool: get_connection_pool(&configuration.database),
        api_client,
        test_user: user,
    };
    app.test_user.store(&app).await;
    app
}

pub struct TestUser {
    pub user_id: Uuid,
    pub username: String,
    pub password: String,
    pub exp_seconds: u64,
}

impl TestUser {
    pub fn generate() -> Self {
        Self {
            user_id: Uuid::new_v4(),
            username: Uuid::new_v4().to_string(),
            password: Uuid::new_v4().to_string(),
            exp_seconds: 1,
        }
    }

    pub async fn login(&self, app: &TestApp) -> String {
        let response = app
            .post_login(
                serde_json::json!({
                    "user": {
                        "username": &self.username,
                        "password": &self.password
                    }
                })
                .to_string(),
            )
            .await;

        let json: Value = response.json().await.expect("expected json response");
        json["user"]["token"].as_str().unwrap().to_string()
    }

    pub async fn logout(&self) {
        thread::sleep(time::Duration::from_secs(self.exp_seconds + 2));
    }

    async fn store(&self, app: &TestApp) {
        let signup_body = serde_json::json!({
            "user": {
                "username": &self.username,
                "password": &self.password
            }
        });
        app.post_signup(signup_body.to_string()).await;
    }
}
