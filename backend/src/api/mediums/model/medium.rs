use sqlx::types::Uuid;

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct StoredMedium {
    pub id: Uuid,
    pub name: String,
}

/// Representation of structure of an medium in the api
#[derive(Debug, serde::Serialize, serde::Deserialize, PartialEq, Eq)]
pub struct MediumData {
    pub name: String,
}

impl From<StoredMedium> for MediumData {
    fn from(m: StoredMedium) -> Self {
        Self { name: m.name }
    }
}
