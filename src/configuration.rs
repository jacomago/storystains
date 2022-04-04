use config::Config;

#[derive(serde::Deserialize)]
pub struct Settings {
    pub database: DatabaseSettings,
    pub application_port: u16,
}

#[derive(serde::Deserialize)]
pub struct DatabaseSettings {
    pub username: String,
    pub password: String,
    pub port: u16,
    pub host: String,
    pub database_name: String,
}

pub fn get_configuration() -> Result<Settings, config::ConfigError> {
    // Initialise our configuration reader

    let mut builder = Config::builder().add_source(config::File::with_name("configuration"));
    match builder.build() {
        Ok(config) => Ok(config.try_deserialize().unwrap()),
        Err(e) => Err(e),
    }
}
