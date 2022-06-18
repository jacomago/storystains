
INSERT INTO emotions (id, name, description, icon_url)
VALUES (
        1,
        'Anger',
        'Strong displeasure against a someone or something.',
        '/emotions/anger.svg'
    ),
    (
        2,
        'Disgust',
        'An aversion to something distasteful.',
        '/emotions/disgust.svg'
    ),
    (
        3,
        'Fear',
        'To expect danger.',
        '/emotions/fear.svg'
    ),
    (4, 'Joy', 'Strong pleasure.', '/emotions/joy.svg'),
    (
        5,
        'Sadness',
        'Unhappiness.',
        '/emotions/sadness.svg'
    ),
    (
        6,
        'Surprise',
        'Reaction to an unexpected event.',
        '/emotions/surprise.svg'
    ),
    (
        7,
        'Outrage',
        'Combination of Anger and disgust.',
        '/emotions/outrage.svg'
    ),
    (
        8,
        'Trapped',
        'Combination of Anger and Fear.',
        '/emotions/trapped.svg'
    ),
    (
        9,
        'Cruelty',
        'Combination of Anger and Joy.',
        '/emotions/cruelty.svg'
    ),
    (
        10,
        'Betrayl',
        'Combination of Anger and Sadness.',
        '/emotions/betrayl.svg'
    ),
    (
        11,
        'What the?',
        'Combination of Anger and Surprise.',
        '/emotions/what-the.svg'
    ),
    (
        12,
        'Horror',
        'Combination of Disgust and Fear.',
        '/emotions/horror.svg'
    ),
    (
        13,
        'Eww',
        'Combination of Disgust and Joy.',
        '/emotions/eww.svg'
    ),
    (
        14,
        'Pain Empathy',
        'Combination of Disgust and Sadness.',
        '/emotions/pain-empathy.svg'
    ),
    (
        15,
        'You ate it!',
        'Combination of Disgust and Surprise.',
        '/emotions/you-ate-it.svg'
    ),
    (
        16,
        'Desperation',
        'Combination of Fear and Joy.',
        '/emotions/desperation.svg'
    ),
    (
        17,
        'Devastation',
        'Combination of Fear and Sadness.',
        '/emotions/devastation.svg'
    ),
    (
        18,
        'Spooked',
        'Combination of Fear and Surprise.',
        '/emotions/spooked.svg'
    ),
    (
        19,
        'Faint Hope',
        'Combination of Joy and Sadness.',
        '/emotions/faint-hope.svg'
    ),
    (
        20,
        'Amazement',
        'Combination of Joy and Surprise.',
        '/emotions/amazement.svg'
    ),
    (
        21,
        'Disappointment',
        'Combination of Sadness and Surprise.',
        '/emotions/disappointment.svg'
    )
    ON CONFLICT (id) DO UPDATE 
    SET name        = excluded.name, 
        description = excluded.description,
        icon_url    = excluded.icon_url;
    ;