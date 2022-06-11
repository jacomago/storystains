use config::Config;
use secrecy::{ExposeSecret, Secret};
use serde_aux::field_attributes::deserialize_number_from_string;
use sqlx::postgres::PgConnectOptions;
use sqlx::postgres::PgSslMode;
use sqlx::ConnectOptions;

/// Nested Configuration of Application
#[derive(serde::Deserialize, Clone)]
pub struct Settings {
    /// Database Settings
    pub database: DatabaseSettings,
    /// Application Settings
    pub application: ApplicationSettings,
    /// The possible input origin for Cross Origin requests
    pub frontend_origin: String,
    /// Folder whre static files are stored
    pub static_files: String,
}

/// Settings for the application
#[derive(serde::Deserialize, Clone)]
pub struct ApplicationSettings {
    /// Port to deploy on
    #[serde(deserialize_with = "deserialize_number_from_string")]
    pub port: u16,
    /// Host to to deploy on
    pub host: String,
    /// Base url
    pub base_url: String,
    /// Initial Secret for jwt encryption
    pub hmac_secret: Secret<String>,
    /// Length of expiry in seconds of token
    pub exp_token_seconds: u64,
}

/// Database settings
#[derive(serde::Deserialize, Clone)]
pub struct DatabaseSettings {
    /// Database username
    pub username: String,
    /// Database password
    pub password: Secret<String>,
    #[serde(deserialize_with = "deserialize_number_from_string")]

    /// Database port
    pub port: u16,
    /// Database host
    pub host: String,
    /// Name of database
    pub database_name: String,
    /// Require use of ssl (not supported by fly, not needed for local)
    pub require_ssl: bool,
}

impl DatabaseSettings {
    /// Connection options without the database
    /// Useful for creating test databases
    pub fn without_db(&self) -> PgConnectOptions {
        let ssl_mode = if self.require_ssl {
            PgSslMode::Require
        } else {
            PgSslMode::Prefer
        };
        PgConnectOptions::new()
            .host(&self.host)
            .username(&self.username)
            .password(self.password.expose_secret())
            .port(self.port)
            .ssl_mode(ssl_mode)
    }
    /// Connection options with the database
    pub fn with_db(&self) -> PgConnectOptions {
        let mut options = self.without_db().database(&self.database_name);
        let _ = options.log_statements(tracing::log::LevelFilter::Trace);
        options
    }
}

/// Retrieves the documentation from the environment
/// Assumes local by default otherwise type is set in the APP_ENVIRONMENT env variable
/// Has a heirachy of Base file, then Environment file, then System Environment variables
/// Of type APP__SUBSCRIPT__OPTION, i.e. APP__APPLICATION__HMAC_SECRET
pub fn get_configuration() -> Result<Settings, config::ConfigError> {
    let base_path = std::env::current_dir().expect("Failed to determine the current directory");
    let configuration_directory = base_path.join("configuration");

    // Detect the running environment.
    // Default to `local` if unspecified.
    let environment: Environment = std::env::var("APP_ENVIRONMENT")
        .unwrap_or_else(|_| "local".into())
        .try_into()
        .expect("Failed to parse APP_ENVIRONMENT.");

    let builder = Config::builder()
        .add_source(config::File::from(configuration_directory.join("base")).required(true))
        .add_source(
            config::File::from(configuration_directory.join(environment.as_str())).required(true),
        )
        .add_source(config::Environment::with_prefix("app").separator("__"));

    match builder.build() {
        Ok(config) => Ok(config.try_deserialize().unwrap()),
        Err(e) => Err(e),
    }
}

/// The possible runtime environment for our application.
pub enum Environment {
    /// Local
    Local,
    /// Production
    Production,
}

impl Environment {
    /// Environment enum as a string
    pub fn as_str(&self) -> &'static str {
        match self {
            Environment::Local => "local",
            Environment::Production => "production",
        }
    }
}

impl TryFrom<String> for Environment {
    type Error = String;
    fn try_from(s: String) -> Result<Self, Self::Error> {
        match s.to_lowercase().as_str() {
            "local" => Ok(Self::Local),
            "production" => Ok(Self::Production),
            other => Err(format!(
                "{} is not a supported environment. Use either `local` or `production`.",
                other
            )),
        }
    }
}
