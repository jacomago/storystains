use crate::api::routes;
use crate::configuration::{FrontendSettings, Settings};
use crate::cors::cors;
use crate::telemetry::get_metrics;
use actix_files::Files;
use actix_session::storage::RedisSessionStore;
use actix_session::SessionMiddleware;
use actix_web::cookie::Key;
use actix_web::dev::{self, Server};
use actix_web::middleware::{NormalizePath, TrailingSlash};
use actix_web::web::Data;
use actix_web::{http, App, HttpServer};
use actix_web_lab::web::spa;
use secrecy::{ExposeSecret, Secret};
use sqlx::postgres::PgPoolOptions;
use sqlx::PgPool;
use std::net::TcpListener;
use tracing_actix_web::TracingLogger;

use crate::configuration::DatabaseSettings;

/// Set up connection pool
pub fn get_connection_pool(configuration: &DatabaseSettings) -> PgPool {
    PgPoolOptions::new()
        .acquire_timeout(std::time::Duration::from_secs(2))
        .max_connections(configuration.max_connections)
        .connect_lazy_with(configuration.with_db())
}

/// The full application
pub struct Application {
    port: u16,
    server: Server,
}

impl Application {
    /// Build the application from configuration
    pub async fn build(configuration: Settings) -> Result<Self, anyhow::Error> {
        let connection_pool = get_connection_pool(&configuration.database);
        let listener = TcpListener::bind(configuration.application.address())?;
        let port = listener.local_addr().unwrap().port();
        let server = run(
            listener,
            connection_pool,
            configuration.frontend,
            configuration.application.base_url,
            HmacSecret(configuration.application.hmac_secret),
            configuration.redis_uri,
        )
        .await?;
        Ok(Self { port, server })
    }

    /// Get the port
    pub fn port(&self) -> u16 {
        self.port
    }

    /// The run method
    pub async fn run_until_stopped(self) -> Result<(), std::io::Error> {
        self.server.await
    }
}

/// Wrapper around base url for passing through as web::Data
pub struct ApplicationBaseUrl(pub String);

/// Wrapper around secret for passing through as web::Data
#[derive(Clone)]
pub struct HmacSecret(pub Secret<String>);

/// Wrapper around Expiry token seconds for passing through as web::Data
#[derive(Clone)]
pub struct ExpTokenSeconds(pub u64);

/// The main startup method for the running the application with all the parts
async fn run(
    listener: TcpListener,
    db_pool: PgPool,
    frontend: FrontendSettings,
    base_url: String,
    hmac_secret: HmacSecret,
    redis_uri: Secret<String>,
) -> Result<Server, anyhow::Error> {
    let db_pool = Data::new(db_pool);

    let base_url = Data::new(ApplicationBaseUrl(base_url));

    let secret_key = Key::from(hmac_secret.0.expose_secret().as_bytes());
    let redis_store = RedisSessionStore::new(redis_uri.expose_secret()).await?;

    let metrics_route =
        |req: &dev::ServiceRequest| req.path() == "/metrics" && req.method() == http::Method::GET;
    let metrics = get_metrics(metrics_route);
    let server = HttpServer::new(move || {
        App::new()
            .wrap(TracingLogger::default())
            .wrap(metrics.clone())
            .wrap(cors(&frontend.origin))
            .wrap(NormalizePath::new(TrailingSlash::Trim))
            .wrap(SessionMiddleware::new(
                redis_store.clone(),
                secret_key.clone(),
            ))
            .configure(routes)
            .service(
                Files::new("/emotions/", format!("{}/emotions", &frontend.image_files))
                    .index_file("index.html"),
            )
            .service(
                spa()
                    .index_file(format!("{}index.html", &frontend.static_files))
                    .static_resources_location(frontend.static_files.to_string())
                    .finish(),
            )
            .app_data(db_pool.clone())
            .app_data(base_url.clone())
            .app_data(Data::new(hmac_secret.clone()))
    })
    .listen(listener)?
    .run();
    Ok(server)
}
