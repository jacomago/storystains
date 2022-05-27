use actix_web::{error::InternalError, web, HttpResponse, ResponseError};

use anyhow::Context;
use reqwest::StatusCode;
use secrecy::Secret;
use sqlx::PgPool;

use crate::{
    api::error_chain_fmt,
    auth::{validate_credentials, AuthError, Credentials},
    session_state::TypedSession,
};

use super::{
    create_user,
    model::{NewPassword, NewUser, NewUsername, UserResponse},
    read_user_from_id,
};

#[derive(thiserror::Error)]
pub enum LoginError {
    #[error("Authentication failed")]
    AuthError(#[source] anyhow::Error),
    #[error("Something went wrong")]
    UnexpectedError(#[from] anyhow::Error),
}

impl std::fmt::Debug for LoginError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        error_chain_fmt(self, f)
    }
}

#[derive(serde::Deserialize)]
pub struct LoginUser {
    user: LoginData,
}

#[derive(serde::Deserialize)]
pub struct LoginData {
    username: String,
    password: Secret<String>,
}

#[tracing::instrument(
    skip(json, pool, session),
    fields(username=tracing::field::Empty, user_id=tracing::field::Empty)
)]
pub async fn login(
    json: web::Json<LoginUser>,
    pool: web::Data<PgPool>,
    session: TypedSession,
) -> Result<HttpResponse, InternalError<LoginError>> {
    let credentials = Credentials {
        username: json.0.user.username,
        password: json.0.user.password,
    };

    tracing::Span::current().record("username", &tracing::field::display(&credentials.username));

    match validate_credentials(credentials, &pool).await {
        Ok(user_id) => {
            tracing::Span::current().record("user_id", &tracing::field::display(&user_id));
            session.renew();
            session
                .insert_user_id(user_id)
                .map_err(|e| login_error(LoginError::UnexpectedError(e.into())))?;
            let user = read_user_from_id(&user_id, &pool)
                .await
                .map_err(|e| login_error(LoginError::UnexpectedError(e)))?;
            Ok(HttpResponse::Ok().json(UserResponse::from(user)))
        }
        Err(e) => {
            let e = match e {
                AuthError::InvalidCredentials(_) => LoginError::AuthError(e.into()),
                AuthError::UnexpectedError(_) => LoginError::UnexpectedError(e.into()),
            };
            Err(login_error(e))
        }
    }
}

fn login_error(e: LoginError) -> InternalError<LoginError> {
    let response = HttpResponse::BadRequest().finish();
    InternalError::from_response(e, response)
}

#[derive(thiserror::Error)]
pub enum SignupError {
    #[error("{0}")]
    ValidationError(String),
    #[error(transparent)]
    UnexpectedError(#[from] anyhow::Error),
}

impl std::fmt::Debug for SignupError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        error_chain_fmt(self, f)
    }
}

impl ResponseError for SignupError {
    fn status_code(&self) -> StatusCode {
        match self {
            SignupError::ValidationError(_) => StatusCode::BAD_REQUEST,
            SignupError::UnexpectedError(_) => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}
#[derive(serde::Deserialize, Debug)]
pub struct SignupUser {
    user: SignupUserData,
}

#[derive(serde::Deserialize, Debug)]
pub struct SignupUserData {
    username: String,
    password: Secret<String>,
}

impl TryFrom<SignupUserData> for NewUser {
    type Error = String;
    fn try_from(value: SignupUserData) -> Result<Self, Self::Error> {
        let username = NewUsername::parse(value.username)?;
        let password = NewPassword::parse(value.password)?;
        Ok(Self { username, password })
    }
}

#[tracing::instrument(name = "Signup a user", skip(pool, json))]
pub async fn signup(
    json: web::Json<SignupUser>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, SignupError> {
    let new_user = json
        .0
        .user
        .try_into()
        .map_err(SignupError::ValidationError)?;
    let stored = create_user(new_user, &pool)
        .await
        .context("Error storing user")?;
    Ok(HttpResponse::Ok().json(UserResponse::from(stored)))
}
