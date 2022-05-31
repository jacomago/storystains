use chrono::{Duration, Utc};
use jwt::{DecodingKey, EncodingKey};
use secrecy::ExposeSecret;
use serde::{Deserialize, Serialize};

use jsonwebtoken as jwt;
use uuid::Uuid;

use crate::startup::{ExpTokenSeconds, HmacSecret};

#[derive(Debug, Deserialize, Serialize)]
pub struct AuthClaim {
    /// timestamp
    pub exp: i64,
    /// user id
    pub id: Uuid,
    pub username: String,
}

impl AuthClaim {
    pub fn token(&self, secret: &HmacSecret) -> String {
        let encoding_key = EncodingKey::from_base64_secret(
            std::str::from_utf8(secret.0.expose_secret().as_bytes()).unwrap(),
        );
        jwt::encode(&jwt::Header::default(), self, &encoding_key.unwrap()).expect("jwt")
    }

    pub fn new(username: &str, user_id: Uuid, exp_token_seconds: &ExpTokenSeconds) -> Self {
        let exp = Utc::now() + Duration::seconds(exp_token_seconds.0.try_into().unwrap());
        Self {
            exp: exp.timestamp(),
            id: user_id,
            username: username.to_string(),
        }
    }
}

/// Decode token into `Auth` struct. If any error is encountered, log it
/// an return None.
pub fn decode_token(token: &str, secret: &HmacSecret, leeway: u64) -> Option<AuthClaim> {
    use jwt::{Algorithm, Validation};

    let decoding_key = DecodingKey::from_base64_secret(
        std::str::from_utf8(secret.0.expose_secret().as_bytes()).unwrap(),
    );

    let mut validation = Validation::new(Algorithm::HS256);
    validation.leeway = leeway;
    jwt::decode(token, &decoding_key.unwrap(), &validation)
        .map_err(|err| {
            eprintln!("Auth decode error: {:?}", err);
        })
        .ok()
        .map(|token_data| token_data.claims)
}
