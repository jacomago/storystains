mod db;
mod test_app;
mod test_user;

use fake::{faker, Fake};
use once_cell::sync::Lazy;
use storystains::telemetry::{get_subscriber, init_subscriber};
pub use test_app::TestApp;
pub use test_user::TestUser;

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

pub fn long_form() -> String {
    faker::lorem::en::Paragraphs(1..3)
        .fake::<Vec<String>>()
        .join("\n")
}
