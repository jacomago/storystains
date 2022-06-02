use actix_web::{error::InternalError, web, HttpResponse, ResponseError};

use anyhow::Context;
use reqwest::StatusCode;
use secrecy::Secret;
use sqlx::PgPool;
use uuid::Uuid;

use crate::{
    api::{error_chain_fmt, reviews::delete_reviews_by_user_id},
    auth::{validate_credentials, AuthClaim, AuthError, Credentials},
    startup::{ExpTokenSeconds, HmacSecret},
};

use super::{
    create_user, delete_user_by_id,
    model::{NewPassword, NewUser, NewUsername, UserResponse},
    read_user_from_id, UserId,
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
    skip(json, pool, exp_token_days, secret),
    fields(username=tracing::field::Empty, user_id=tracing::field::Empty)
)]
pub async fn login(
    json: web::Json<LoginUser>,
    pool: web::Data<PgPool>,
    exp_token_days: web::Data<ExpTokenSeconds>,
    secret: web::Data<HmacSecret>,
) -> Result<HttpResponse, InternalError<LoginError>> {
    let credentials = Credentials {
        username: json.0.user.username,
        password: json.0.user.password,
    };

    tracing::Span::current().record("username", &tracing::field::display(&credentials.username));

    match validate_credentials(credentials, &pool).await {
        Ok(user_id) => {
            let user = read_user_from_id(&user_id, &pool)
                .await
                .map_err(|e| login_error(LoginError::UnexpectedError(e)))?;
            let token = AuthClaim::new(&user.username, user_id, &exp_token_days).token(&secret);
            Ok(HttpResponse::Ok().json(UserResponse::from((user, token))))
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

// Return an opaque 500 while preserving the error root's cause for logging.
pub fn e500<T>(e: T) -> actix_web::Error
where
    T: std::fmt::Debug + std::fmt::Display + 'static,
{
    actix_web::error::ErrorInternalServerError(e)
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

#[tracing::instrument(name = "Signup a user", skip(pool, json, exp_token_days, secret))]
pub async fn signup(
    json: web::Json<SignupUser>,
    pool: web::Data<PgPool>,
    exp_token_days: web::Data<ExpTokenSeconds>,
    secret: web::Data<HmacSecret>,
) -> Result<HttpResponse, SignupError> {
    let new_user = json
        .0
        .user
        .try_into()
        .map_err(SignupError::ValidationError)?;
    let stored = create_user(new_user, &pool)
        .await
        .context("Error storing user")?;
    let user_id = Uuid::from_u128(stored.user_id.as_u128());
    let token = AuthClaim::new(&stored.username, user_id, &exp_token_days).token(&secret);
    Ok(HttpResponse::Ok().json(UserResponse::from((stored, token))))
}

#[derive(thiserror::Error)]
pub enum DeleteUserError {
    #[error(transparent)]
    UnexpectedError(#[from] anyhow::Error),
}

impl std::fmt::Debug for DeleteUserError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        error_chain_fmt(self, f)
    }
}

impl ResponseError for DeleteUserError {
    fn status_code(&self) -> StatusCode {
        match self {
            DeleteUserError::UnexpectedError(_) => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}

#[tracing::instrument(skip(pool, user_id), fields())]
pub async fn delete_user(
    user_id: web::ReqData<UserId>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, DeleteUserError> {
    let user_id = user_id.into_inner();
    let mut transaction = pool
        .begin()
        .await
        .context("Failed to acquire a Postgres connection from the pool")?;
    delete_reviews_by_user_id(&user_id, &mut transaction)
        .await
        .context("Failed to delete new reviews fromthe database.")?;
    delete_user_by_id(&user_id, &mut transaction)
        .await
        .context("Failed to delete user from the database")?;
    transaction
        .commit()
        .await
        .context("Failed to commit SQL transaction to delete user and data.")?;

    Ok(HttpResponse::Ok().finish())
}
