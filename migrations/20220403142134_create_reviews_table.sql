CREATE TABLE reviews(
    id uuid NOT NULL,
    PRIMARY KEY (id),
    title TEXT NOT NULL UNIQUE,
    review TEXT NOT NULL,
    created_at timestamptz NOT NULL
);