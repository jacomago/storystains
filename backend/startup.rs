use crate::api::{
    delete_review_by_slug, delete_user, get_review, get_reviews, login, post_review, put_review,
    signup,
};
use crate::auth::bearer_auth;
use crate::configuration::Settings;
use crate::cors::cors;
use crate::health_check::health_check;
use actix_files::Files;
use actix_web::dev::Server;
use actix_web::web::Data;
use actix_web::{web, App, HttpServer};
use actix_web_httpauth::middleware::HttpAuthentication;
use secrecy::Secret;
use sqlx::postgres::PgPoolOptions;
use sqlx::PgPool;
use std::net::TcpListener;
use tracing_actix_web::TracingLogger;

use crate::configuration::DatabaseSettings;

pub fn get_connection_pool(configuration: &DatabaseSettings) -> PgPool {
    PgPoolOptions::new()
        .connect_timeout(std::time::Duration::from_secs(2))
        .connect_lazy_with(configuration.with_db())
}

pub struct Application {
    port: u16,
    server: Server,
}

impl Application {
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
            configuration.application.exp_token_seconds,
        )
        .await?;
        Ok(Self { port, server })
    }

    pub fn port(&self) -> u16 {
        self.port
    }

    pub async fn run_until_stopped(self) -> Result<(), std::io::Error> {
        self.server.await
    }
}

pub struct ApplicationBaseUrl(pub String);

#[derive(Clone)]
pub struct HmacSecret(pub Secret<String>);

#[derive(Clone)]
pub struct ExpTokenSeconds(pub u64);

async fn run(
    listener: TcpListener,
    db_pool: PgPool,
    base_url: String,
    hmac_secret: Secret<String>,
    frontend_origin: String,
    exp_token_seconds: u64,
) -> Result<Server, anyhow::Error> {
    let db_pool = Data::new(db_pool);

    let base_url = Data::new(ApplicationBaseUrl(base_url));

    let server = HttpServer::new(move || {
        App::new()
            .wrap(TracingLogger::default())
            .wrap(cors(&frontend_origin))
            .configure(routes)
            .app_data(db_pool.clone())
            .app_data(base_url.clone())
            .app_data(Data::new(HmacSecret(hmac_secret.clone())))
            .app_data(Data::new(ExpTokenSeconds(exp_token_seconds)))
    })
    .listen(listener)?
    .run();
    Ok(server)
}

fn routes(cfg: &mut web::ServiceConfig) {
    // TODO is this a nice hack??
    let auth_reviews = HttpAuthentication::bearer(bearer_auth);
    let auth_users = HttpAuthentication::bearer(bearer_auth);
    cfg.service(
        web::scope("")
            .route("/health_check", web::get().to(health_check))
            .route("/signup", web::post().to(signup))
            .route("/login", web::post().to(login))
            .route("/reviews", web::get().to(get_reviews))
            .route("/reviews/{slug}", web::get().to(get_review))
            .service(
                web::scope("/reviews")
                    .wrap(auth_reviews)
                    .route("", web::post().to(post_review))
                    .route("/{slug}", web::put().to(put_review))
                    .route("/{slug}", web::delete().to(delete_review_by_slug)),
            )
            .service(
                web::scope("/users")
                    .wrap(auth_users)
                    .route("", web::delete().to(delete_user)),
            )
            .service(Files::new("/", "./static/root/").index_file("index.html")),
    );
}
