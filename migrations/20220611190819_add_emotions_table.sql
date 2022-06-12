CREATE TABLE emotions(
    id INTEGER NOT NULL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL UNIQUE
);
CREATE TABLE review_emotions(
    id uuid PRIMARY KEY,
    review_id uuid NOT NULL REFERENCES reviews(id),
    emotion_id SERIAL REFERENCES emotions(id),
    position INTEGER NOT NULL,
    notes TEXT,
    UNIQUE(review_id, emotion_id, position)
);