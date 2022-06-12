use crate::api::{
    db_check, delete_review_by_slug, delete_user, get_emotions, get_review, get_reviews,
    health_check, login, post_review, post_review_emotion, put_review, signup,
};

use crate::auth::bearer_auth;
use crate::configuration::Settings;
use crate::cors::cors;
use crate::telemetry::get_metrics;
use actix_files::Files;
use actix_web::dev::{self, Server};
use actix_web::web::Data;
use actix_web::{http, web, App, HttpServer};
use actix_web_httpauth::middleware::HttpAuthentication;
use secrecy::Secret;
use sqlx::postgres::PgPoolOptions;
use sqlx::PgPool;
use std::net::TcpListener;
use tracing_actix_web::TracingLogger;

use crate::configuration::DatabaseSettings;

/// Set up connection pool
pub fn get_connection_pool(configuration: &DatabaseSettings) -> PgPool {
    PgPoolOptions::new()
        .connect_timeout(std::time::Duration::from_secs(2))
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

        let address = format!(
            "{}:{}",
            configuration.application.host, configuration.application.port
        );
        let listener = TcpListener::bind(&address)?;
        let port = listener.local_addr().unwrap().port();
        let server = run(
            listener,
            connection_pool,
            configuration.application.base_url,
            configuration.application.hmac_secret,
            configuration.frontend_origin,
            configuration.static_files,
            configuration.application.exp_token_seconds,
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
    base_url: String,
    hmac_secret: Secret<String>,
    frontend_origin: String,
    static_files: String,
    exp_token_seconds: u64,
) -> Result<Server, anyhow::Error> {
    let db_pool = Data::new(db_pool);

    let base_url = Data::new(ApplicationBaseUrl(base_url));
    let metrics_route =
        |req: &dev::ServiceRequest| req.path() == "/metrics" && req.method() == http::Method::GET;
    let metrics = get_metrics(metrics_route);
    let server = HttpServer::new(move || {
        App::new()
            .wrap(TracingLogger::default())
            .wrap(metrics.clone())
            .wrap(cors(&frontend_origin))
            .configure(routes)
            .service(Files::new("/", &static_files).index_file("index.html"))
            .app_data(db_pool.clone())
            .app_data(base_url.clone())
            .app_data(Data::new(HmacSecret(hmac_secret.clone())))
            .app_data(Data::new(ExpTokenSeconds(exp_token_seconds)))
    })
    .listen(listener)?
    .run();
    Ok(server)
}

/// Configuration of all the routes
/// Currently creates two duplicate authenticator middlewares for different routes
/// which isn't elegant
fn routes(cfg: &mut web::ServiceConfig) {
    // TODO is this a nice hack??
    let auth_reviews = HttpAuthentication::bearer(bearer_auth);
    let auth_users = HttpAuthentication::bearer(bearer_auth);
    let _ = cfg.service(
        web::scope("/api")
            .route("/health_check", web::get().to(health_check))
            .route("/db_check", web::get().to(db_check))
            .route("/signup", web::post().to(signup))
            .route("/login", web::post().to(login))
            .route("/emotions", web::get().to(get_emotions))
            .route("/reviews", web::get().to(get_reviews))
            .route("/reviews/{slug}", web::get().to(get_review))
            .service(
                web::scope("/reviews")
                    .wrap(auth_reviews)
                    .route("", web::post().to(post_review))
                    .route("/{slug}", web::put().to(put_review))
                    .route("/{slug}", web::delete().to(delete_review_by_slug))
                    .route("/{slug}/emotions", web::post().to(post_review_emotion)),
            )
            .service(
                web::scope("/users")
                    .wrap(auth_users)
                    .route("", web::delete().to(delete_user)),
            ),
    );
}
