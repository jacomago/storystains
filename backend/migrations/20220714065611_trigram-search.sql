create EXTENSION pg_trgm;
create INDEX trgm_idx_story_title on stories using gin (title gin_trgm_ops);
create INDEX trgm_idx_creator on creators using gin (name gin_trgm_ops);