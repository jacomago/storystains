use serde::{Deserialize, Serialize};
use sqlx::types::Uuid;

#[derive(Clone, Debug, PartialEq)]
pub struct StoredMedium {
    pub id: Uuid,
    pub name: String,
}

/// Representation of structure of an medium in the api
#[derive(Debug, Serialize, Deserialize, PartialEq)]
pub struct MediumData {
    pub name: String,
}

impl From<StoredMedium> for MediumData {
    fn from(m: StoredMedium) -> Self {
        Self { name: m.name }
    }
}
