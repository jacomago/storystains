-- Create mediums and add some first ones.
CREATE TABLE mediums(
    id uuid PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);
-- Insert some initial values for mediums
INSERT INTO mediums (id, name)
VALUES (
        '971E039C-0EFB-42AE-A309-27C8221CDD48',
        'Book'
    ),
    (
        '638BC2BE-D433-40FF-979D-27CB3A328677',
        'Film'
    ),
    (
        '520AC5B9-7906-4C0B-B8E4-CC0F1D81E62D',
        'Short Story'
    ),
    (
        '73b9334d-65e5-442a-ac23-a7c335c8df67',
        'TV Show'
    ),
    (
        '851afc5b-9fb5-473e-b811-5fb3aac35d20',
        'TV Series'
    ),
    (
        '3f60b683-3cf6-4aca-a17a-5f1da104b9d7',
        'Comic Book'
    ),
    (
        '26531624-00eb-43cd-9910-476e7ab77070',
        'Comic Series'
    ),
    (
        '27ee1ae9-beb8-4730-afd3-a9bddd0f2031',
        'Manga Book'
    ),
    (
        '3e92826b-544f-48ad-839f-ba56fd5fc393',
        'Audio Book'
    ),
    (
        'cbcea1dd-00ba-49a4-89c8-9ee896c13896',
        'Podcast Episode'
    ),
    (
        '45b5e391-5998-4110-b89e-d6e4547a3101',
        'Article'
    ),
    (
        '9a5cc001-4bee-4aea-b4a1-5eba084d49fc',
        'Podcast'
    );
-- Create a table of creators
CREATE TABLE creators(id uuid PRIMARY KEY, name TEXT NOT NULL UNIQUE);
-- Insert Anonymous Creator to start with
INSERT INTO creators(id, name)
VALUES (
        'aea34724-9601-4555-96d2-e7744055c393',
        'Anonymous'
    );
-- Create a table of stories
CREATE TABLE stories(
    id uuid PRIMARY KEY,
    title TEXT NOT NULL,
    medium_id uuid NOT NULL REFERENCES mediums(id),
    creator_id uuid NOT NULL REFERENCES creators(id),
    UNIQUE(title, creator_id, medium_id)
);
-- Install the uuid genererator for postgres
CREATE extension IF NOT EXISTS "uuid-ossp";
-- Insert into stories the values from reviews
INSERT INTO stories (id, title, creator_id, medium_id)
SELECT uuid_generate_v4(),
    title,
    'aea34724-9601-4555-96d2-e7744055c393',
    '971E039C-0EFB-42AE-A309-27C8221CDD48'
FROM reviews;
-- Add story id column to reviews
ALTER TABLE reviews
ADD COLUMN story_id uuid REFERENCES stories (id);
-- Copy ids from the stories table
UPDATE reviews
SET story_id = stories.id
FROM stories
WHERE stories.title = reviews.title;
-- Make the story_id column not null
ALTER TABLE reviews
ALTER COLUMN story_id SET NOT NULL;
-- Remove the title COLUMN from reviews
ALTER TABLE reviews DROP COLUMN title;