use storystains::configuration::get_configuration;
use storystains::startup::Application;
use storystains::telemetry::{get_subscriber, init_subscriber};

/// Runs the full application
#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let subscriber = get_subscriber("storystains".into(), "info".into(), std::io::stdout);
    init_subscriber(subscriber);

    let configuration = get_configuration().expect("Failed to read configuration.");
    tracing_log::log::info!("base url {}", configuration.application.base_url);
    let application = Application::build(configuration).await?;
    application.run_until_stopped().await?;
    Ok(())
}
