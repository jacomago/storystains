use actix_web::{error::InternalError, web, HttpResponse, ResponseError};

use anyhow::Context;
use reqwest::StatusCode;
use secrecy::Secret;
use sqlx::PgPool;

use crate::{
    api::{error_chain_fmt, reviews::delete_reviews_by_user_id},
    auth::{validate_credentials, AuthClaim, AuthError, AuthUser, Credentials},
    startup::{ExpTokenSeconds, HmacSecret},
};

use super::{
    create_user, delete_user_by_id,
    model::{NewPassword, NewUser, NewUsername, UserResponse},
    read_user_by_id, UserId,
};

/// Errors that can happen during login flow
#[derive(thiserror::Error)]
pub enum LoginError {
    /// Auth failure
    #[error("Authentication failed")]
    AuthError(#[source] anyhow::Error),
    /// Other type of error
    #[error("Something went wrong")]
    UnexpectedError(#[from] anyhow::Error),
}

impl std::fmt::Debug for LoginError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        error_chain_fmt(self, f)
    }
}

/// Input of user for login api
#[derive(serde::Deserialize)]
pub struct LoginUser {
    user: LoginData,
}

/// Input of data for user
#[derive(serde::Deserialize)]
pub struct LoginData {
    username: String,
    password: Secret<String>,
}

/// Login endpoint handler
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

    let _ = tracing::Span::current()
        .record("username", &tracing::field::display(&credentials.username));

    match validate_credentials(credentials, &pool).await {
        Ok(user_id) => {
            let user = read_user_by_id(&user_id, &pool)
                .await
                .map_err(|e| login_error(LoginError::UnexpectedError(e.into())))?;
            let token = AuthClaim::new(
                AuthUser {
                    username: user.username.to_string(),
                    user_id,
                },
                &exp_token_days,
            )
            .token(&secret);
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

/// Errors from Signup flow
#[derive(thiserror::Error)]
pub enum SignupError {
    /// Incorrect username or password
    #[error("{0}")]
    ValidationError(String),
    /// Something else went wrong
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

/// Input for signup api
#[derive(serde::Deserialize, Debug)]
pub struct SignupUser {
    user: SignupUserData,
}

/// input for signup api
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

/// Sign up api handler
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
    let user_id = stored.user_id.into();
    let token = AuthClaim::new(
        AuthUser {
            username: stored.username.to_string(),
            user_id,
        },
        &exp_token_days,
    )
    .token(&secret);
    Ok(HttpResponse::Ok().json(UserResponse::from((stored, token))))
}

/// Delete User api error
#[derive(thiserror::Error)]
pub enum DeleteUserError {
    /// We only expect the unexpected
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

/// Delete user api handler currently deletes all user's review
#[tracing::instrument(skip(pool, auth_user), fields())]
pub async fn delete_user(
    auth_user: web::ReqData<AuthUser>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, DeleteUserError> {
    let user_id = auth_user.into_inner().user_id;
    let mut transaction = pool
        .begin()
        .await
        .context("Failed to acquire a Postgres connection from the pool")?;
    delete_reviews_by_user_id(&user_id, &mut transaction)
        .await
        .context("Failed to delete new reviews from the database.")?;
    delete_user_by_id(&user_id, &mut transaction)
        .await
        .context("Failed to delete user from the database")?;
    transaction
        .commit()
        .await
        .context("Failed to commit SQL transaction to delete user and data.")?;

    Ok(HttpResponse::Ok().finish())
}
