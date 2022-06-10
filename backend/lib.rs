//! Story Stains is a story review site using the actix web framework for the backend
//! api. The objects are split up into different modules in the api module.

#![deny(
    missing_docs,
    trivial_casts,
    trivial_numeric_casts,
    unused_extern_crates,
    unused_import_braces,
    unused_results,
    variant_size_differences
)]

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
