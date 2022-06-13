//! Story Stains is a story review site using the actix web framework for the backend
//! api. The objects are split up into different modules in the api module.

#![deny(missing_docs, rust_2018_idioms, rust_2021_compatibility)]

/// Api is where all the individual feature modules exist
/// Can intermingle, especially with user part
// TODO (might want to split user out)
pub mod api;

/// Authentication code including middleware
pub mod auth;

/// Loading Configuration module
pub mod configuration;

/// Cross Origin Requsts module
pub mod cors;

/// Startup code for beginning the application
pub mod startup;

/// Setup Telemetry for logs
pub mod telemetry;
