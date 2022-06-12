insert into reviews(
        id,
        slug,
        title,
        body,
        created_at,
        updated_at,
        user_id
    )
values "bfd52624-57aa-4d9a-8bb8-849226fc4abe",
    "slug",
    "slug",
    "slug",
    now(),
    now(),
    1
);
INSERT INTO review_emotions (
        id,
        review_id,
        emotion_id,
        position,
        notes
    )
SELECT (
        "334",
        review_id,
        4,
        3,
        "notes"
    )
FROM reviews
WHERE slug = "fat";