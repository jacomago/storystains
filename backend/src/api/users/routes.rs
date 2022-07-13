use actix_web::{web, HttpResponse};

use anyhow::Context;
use secrecy::Secret;
use sqlx::PgPool;

use crate::{
    api::{reviews::delete_reviews_by_user_id, shared::ApiError},
    auth::{validate_credentials, AuthClaim, AuthError, AuthUser, Credentials},
    startup::{ExpTokenSeconds, HmacSecret},
};

use super::{
    create_user, delete_user_by_id,
    model::{NewPassword, NewUser, NewUsername, UserResponse},
    read_user_by_id,
};

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
) -> Result<HttpResponse, ApiError> {
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
                .map_err(|e| anyhow::format_err!(e))?;
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
        Err(e) => match e {
            AuthError::InvalidCredentials(_) => Err(ApiError::Auth(e.into())),
            AuthError::UnexpectedError(_) => Err(ApiError::Unexpected(e.into())),
        },
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
) -> Result<HttpResponse, ApiError> {
    let new_user = json.0.user.try_into().map_err(ApiError::Validation)?;
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

/// Delete user api handler currently deletes all user's review
#[tracing::instrument(skip(pool, auth_user), fields())]
pub async fn delete_user(
    auth_user: web::ReqData<AuthUser>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ApiError> {
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
