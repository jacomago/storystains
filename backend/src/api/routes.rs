use actix_web::web;
use actix_web_lab::middleware::from_fn;

use crate::auth::reject_anonymous_users;

use super::{
    emotions::routes::*, health_check::*, mediums::routes::*, review_emotion::routes::*,
    reviews::routes::*, stories::routes::*, users::routes::*,
};

/// Configuration of all the routes
/// Currently creates two duplicate authenticator middlewares for different routes
/// which isn't elegant
pub fn routes(cfg: &mut web::ServiceConfig) {
    let _ = cfg.service(
        web::scope("/api")
            .route("/health_check", web::get().to(health_check))
            .route("/db_check", web::get().to(db_check))
            .route("/signup", web::post().to(signup))
            .route("/login", web::post().to(login))
            .route("/emotions", web::get().to(get_emotions))
            .route("/mediums", web::get().to(get_mediums))
            .route("/stories", web::get().to(get_stories))
            .route("/reviews", web::get().to(get_reviews))
            .route("/reviews/{username}/{slug}", web::get().to(get_review))
            .route(
                "/reviews/{username}/{slug}/emotions/{position}",
                web::get().to(get_review_emotion),
            )
            .service(
                web::scope("/reviews")
                    .wrap(from_fn(reject_anonymous_users))
                    .route("", web::post().to(post_review))
                    .route("/{username}/{slug}", web::put().to(put_review))
                    .route(
                        "/{username}/{slug}",
                        web::delete().to(delete_review_by_slug),
                    )
                    .route(
                        "/{username}/{slug}/emotions",
                        web::post().to(post_review_emotion),
                    )
                    .route(
                        "/{username}/{slug}/emotions/{position}",
                        web::put().to(put_review_emotion),
                    )
                    .route(
                        "/{username}/{slug}/emotions/{position}",
                        web::delete().to(delete_review_emotion),
                    ),
            )
            .service(
                web::scope("/stories")
                    .wrap(from_fn(reject_anonymous_users))
                    .route("", web::post().to(post_story)),
            )
            .service(
                web::scope("/users")
                    .wrap(from_fn(reject_anonymous_users))
                    .route("", web::delete().to(delete_user)),
            ),
    );
}
