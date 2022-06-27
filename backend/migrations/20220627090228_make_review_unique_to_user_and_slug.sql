-- Add migration script here
ALTER TABLE reviews
DROP CONSTRAINT reviews_slug_key;

ALTER TABLE reviews
ADD CONSTRAINT unique_user_slug UNIQUE (slug, user_id);