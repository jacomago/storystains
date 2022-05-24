CREATE TABLE reviews(
    id uuid NOT NULL,
    PRIMARY KEY (id),
    slug TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    review TEXT NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL
);