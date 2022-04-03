use actix_web::dev::Server;
use actix_web::{web, App,  HttpServer};
use std::net::TcpListener;

pub fn run(listener: TcpListener) -> Result<Server, std::io::Error> {
    let server = HttpServer::new(|| {
        App::new()
            .route("/health_check", web::get().to(health_check))
            .route("/reviews", web::post().to(review))
    })
    .listen(listener)?
    .run();
    Ok(server)
}
