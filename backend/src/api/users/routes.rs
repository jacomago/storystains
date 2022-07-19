use actix_web::{web, HttpResponse};

use anyhow::Context;
use secrecy::Secret;
use sqlx::PgPool;

use crate::{
    api::{
        reviews::delete_reviews_by_user_id,
        shared::{
            access_control::{access_control_block, ACLOption},
            ApiError,
        },
    },
    auth::{e500, validate_credentials, AuthError, AuthUser, Credentials},
    session_state::TypedSession,
};

use super::{
    create_user, db,
    model::{NewPassword, NewUser, NewUsername, UserResponse},
    read_user_by_id, UserId,
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
    skip(json, pool, session),
    fields(username=tracing::field::Empty, user_id=tracing::field::Empty)
)]
pub async fn login(
    json: web::Json<LoginUser>,
    pool: web::Data<PgPool>,
    session: TypedSession,
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
            session.renew();
            session
                .insert_user(AuthUser::from(user.clone()))
                .map_err(|e| (AuthError::UnexpectedError(e.into())))?;
            Ok(HttpResponse::Ok().json(UserResponse::from(user)))
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
#[tracing::instrument(name = "Signup a user", skip(pool, json, session))]
pub async fn signup(
    json: web::Json<SignupUser>,
    pool: web::Data<PgPool>,
    session: TypedSession,
) -> Result<HttpResponse, ApiError> {
    let new_user = json.0.user.try_into().map_err(ApiError::Validation)?;
    let stored = create_user(new_user, &pool)
        .await
        .context("Error storing user")?;
    session.renew();
    session
        .insert_user(AuthUser::from(stored.clone()))
        .map_err(|e| (AuthError::UnexpectedError(e.into())))?;
    Ok(HttpResponse::Ok().json(UserResponse::from(stored)))
}

pub async fn log_out(session: TypedSession) -> Result<HttpResponse, actix_web::Error> {
    if session.get_user().map_err(e500)?.is_none() {
        Ok(HttpResponse::Ok().finish())
    } else {
        session.log_out();
        Ok(HttpResponse::Ok().finish())
    }
}

/// Delete user currently deletes all user's review
#[tracing::instrument(name = "Delete user by id route", skip(pool), fields())]
pub async fn delete_user_by_id(user_id: UserId, pool: web::Data<PgPool>) -> Result<(), ApiError> {
    let mut transaction = pool
        .begin()
        .await
        .context("Failed to acquire a Postgres connection from the pool")?;
    delete_reviews_by_user_id(&user_id, &mut transaction)
        .await
        .context("Failed to delete new reviews from the database.")?;
    db::delete_user_by_id(&user_id, &mut transaction)
        .await
        .context("Failed to delete user from the database")?;
    transaction
        .commit()
        .await
        .context("Failed to commit SQL transaction to delete user and data.")?;

    Ok(())
}

/// Delete user api handler currently deletes all user's review
#[tracing::instrument("Delete user by login route", skip(pool, auth_user, session), fields())]
pub async fn delete_user(
    auth_user: web::ReqData<AuthUser>,
    pool: web::Data<PgPool>,
    session: TypedSession,
) -> Result<HttpResponse, ApiError> {
    let user_id = auth_user.into_inner().user_id;
    delete_user_by_id(user_id, pool).await?;
    session.log_out();
    Ok(HttpResponse::Ok().finish())
}

/// Delete user api handler currently deletes all user's review
#[tracing::instrument("Delete user by username route", skip(pool, auth_user), fields())]
pub async fn delete_user_by_username(
    username: web::Path<String>,
    auth_user: web::ReqData<AuthUser>,
    pool: web::Data<PgPool>,
) -> Result<HttpResponse, ApiError> {
    let new_username = NewUsername::parse(username.to_string()).map_err(ApiError::Validation)?;
    access_control_block(&new_username, &auth_user, ACLOption::OwnerAndAdmin).await?;
    let user_id = db::read_user_by_username(&new_username, pool.get_ref())
        .await?
        .user_id;
    delete_user_by_id(user_id.into(), pool).await?;
    Ok(HttpResponse::Ok().finish())
}
