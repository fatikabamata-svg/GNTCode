-- Guinea National Tour - MySQL seed data
-- Import this file after database/migrations/001_initial_schema.sql.

SET NAMES utf8mb4;

INSERT INTO categories (name, slug, description) VALUES
    ('Îles et plages', 'iles-et-plages', 'Destinations côtières, îles, plages et excursions maritimes.'),
    ('Nature et montagnes', 'nature-et-montagnes', 'Plateaux, montagnes, cascades, réserves et sites naturels.'),
    ('Villes et patrimoine', 'villes-et-patrimoine', 'Villes, quartiers historiques, culture urbaine et patrimoine.'),
    ('Réserves et biodiversité', 'reserves-et-biodiversite', 'Aires naturelles, faune, flore et biodiversité remarquable.')
ON DUPLICATE KEY UPDATE
    description = VALUES(description);

INSERT INTO regions (name, description) VALUES
    ('Boké', 'Région maritime et minière du nord-ouest de la Guinée.'),
    ('Moyenne Guinée', 'Région de plateaux, vallées, cascades et paysages du Fouta Djallon.'),
    ('Conakry', 'Capitale de la Guinée, centre administratif, économique et culturel.'),
    ('Guinée forestière', 'Région forestière du sud-est, connue pour sa biodiversité et ses reliefs.')
ON DUPLICATE KEY UPDATE
    description = VALUES(description);

INSERT INTO destinations (
    name,
    slug,
    short_description,
    long_description,
    destination_type,
    region_id,
    category_id,
    prefecture,
    locality,
    source_url,
    verification_status,
    is_featured,
    is_active
) VALUES
    (
        'Île de Room',
        'ile-de-room',
        'Destination insulaire à valoriser pour les circuits côtiers de Boké.',
        'Île de Room est intégrée comme destination phare du projet Guinea National Tour. Les informations détaillées, coordonnées GPS, images officielles et modalités d’accès seront enrichies après vérification éditoriale.',
        'île',
        (SELECT id FROM regions WHERE name = 'Boké'),
        (SELECT id FROM categories WHERE slug = 'iles-et-plages'),
        'Boké',
        'Boké',
        'https://www.facebook.com/61573989154315/posts/122168508350799638/?app=fbl',
        'pending',
        TRUE,
        TRUE
    ),
    (
        'Fouta Djallon',
        'fouta-djallon',
        'Plateau emblématique de la Moyenne Guinée, réputé pour ses reliefs et cascades.',
        'Le Fouta Djallon constitue l’un des grands pôles touristiques naturels de la Guinée. Cette fiche servira de base à l’affichage détaillé des circuits, saisons recommandées et informations pratiques.',
        'plateau / région',
        (SELECT id FROM regions WHERE name = 'Moyenne Guinée'),
        (SELECT id FROM categories WHERE slug = 'nature-et-montagnes'),
        'Labé',
        'Fouta Djallon',
        'https://www.facebook.com/61573989154315/posts/122154774242799638/?app=fbl',
        'verified',
        TRUE,
        TRUE
    ),
    (
        'Ville de Conakry',
        'ville-de-conakry',
        'Capitale guinéenne, porte d’entrée culturelle, administrative et maritime du pays.',
        'La Ville de Conakry est référencée comme destination urbaine centrale du projet. Elle permettra de présenter les sites culturels, administratifs, historiques et les expériences en bord de mer.',
        'ville',
        (SELECT id FROM regions WHERE name = 'Conakry'),
        (SELECT id FROM categories WHERE slug = 'villes-et-patrimoine'),
        'Conakry',
        'Conakry',
        'https://www.facebook.com/61573989154315/posts/122110608842799638/?app=fbl',
        'verified',
        TRUE,
        TRUE
    ),
    (
        'Mont Nimba et crapauds géants',
        'mont-nimba-et-crapauds-geants',
        'Réserve et montagne de la Guinée forestière associée à une biodiversité remarquable.',
        'Le Mont Nimba et les crapauds géants sont intégrés comme destination naturelle majeure. La fiche est prête à recevoir des données complémentaires sur l’accès, la conservation et les conditions de visite.',
        'réserve / montagne',
        (SELECT id FROM regions WHERE name = 'Guinée forestière'),
        (SELECT id FROM categories WHERE slug = 'reserves-et-biodiversite'),
        'N’Zérékoré',
        'Mont Nimba',
        'https://www.facebook.com/61573989154315/posts/122109586478799638/?app=fbl',
        'verified',
        TRUE,
        TRUE
    )
ON DUPLICATE KEY UPDATE
    short_description = VALUES(short_description),
    long_description = VALUES(long_description),
    destination_type = VALUES(destination_type),
    region_id = VALUES(region_id),
    category_id = VALUES(category_id),
    prefecture = VALUES(prefecture),
    locality = VALUES(locality),
    source_url = VALUES(source_url),
    verification_status = VALUES(verification_status),
    is_featured = VALUES(is_featured),
    is_active = VALUES(is_active);
