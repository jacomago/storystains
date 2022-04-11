use crate::catalog::Catalog;
use crate::configuration::{Settings, CatalogSettings};
use actix_web::dev::Server;
use actix_web::web::Data;
use actix_web::{web, App, HttpServer};
use sqlx::postgres::PgPoolOptions;
use sqlx::PgPool;
use std::net::TcpListener;
use tracing_actix_web::TracingLogger;

use crate::configuration::DatabaseSettings;
use crate::routes::{health_check, review};

pub fn get_connection_pool(configuration: &DatabaseSettings) -> PgPool {
    PgPoolOptions::new()
        .connect_timeout(std::time::Duration::from_secs(2))
        .connect_lazy_with(configuration.with_db())
}

fn get_catalog(configuration: &CatalogSettings) -> Catalog {
    Catalog::new(configuration.base_url)
}

// A new type to hold the newly built server and its port
pub struct Application {
    port: u16,
    server: Server,
}

impl Application {
    // We have converted the `build` function into a constructor for
    // `Application`.
    pub async fn build(configuration: Settings) -> Result<Self, std::io::Error> {
        let connection_pool = get_connection_pool(&configuration.database);

        let address = format!(
            "{}:{}",
            configuration.application.host, configuration.application.port
        );
        let listener = TcpListener::bind(&address)?;
        let port = listener.local_addr().unwrap().port();

        let catalog = get_catalog(&configuration.catalog);
        
        let server = run(listener, connection_pool, catalog)?;
        // We "save" the bound port in one of `Application`'s fields
        Ok(Self { port, server })
    }

    pub fn port(&self) -> u16 {
        self.port
    }

    // A more expressive name that makes it clear that
    // this function only returns when the application is stopped.
    pub async fn run_until_stopped(self) -> Result<(), std::io::Error> {
        self.server.await
    }
}

pub fn run(listener: TcpListener, db_pool: PgPool, catalog: Catalog) -> Result<Server, std::io::Error> {
    let db_pool = Data::new(db_pool);
    let catalog = Data::new(catalog);
    let server = HttpServer::new(move || {
        App::new()
            .wrap(TracingLogger::default())
            .route("/health_check", web::get().to(health_check))
            // A new entry in our routing table for POST /reviews requests
            .route("/reviews", web::post().to(review))
            .app_data(db_pool.clone())
            .app_data(catalog.clone())
    })
    .listen(listener)?
    .run();
    Ok(server)
}
