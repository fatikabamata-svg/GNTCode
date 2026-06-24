PRAGMA foreign_keys = ON;

INSERT INTO users (email, password_hash, full_name, phone, role) VALUES
    ('admin@solide.local', 'change-me-before-production', 'Administrateur Solide', '+224000000000', 'admin'),
    ('guide@solide.local', 'change-me-before-production', 'Guide Démo', '+224111111111', 'guide'),
    ('client@solide.local', 'change-me-before-production', 'Client Démo', '+224222222222', 'customer');

INSERT INTO destinations (name, region, description, latitude, longitude) VALUES
    ('Îles de Loos', 'Conakry', 'Archipel côtier apprécié pour les excursions et plages.', 9.4667, -13.8333),
    ('Fouta-Djalon', 'Moyenne-Guinée', 'Massif montagneux connu pour ses cascades et randonnées.', 10.8333, -12.5000);

INSERT INTO tours (destination_id, guide_id, title, description, duration_days, capacity, price_amount, status, starts_on, ends_on) VALUES
    (1, 2, 'Week-end aux Îles de Loos', 'Découverte guidée des plages, villages et sites historiques.', 2, 12, 850000, 'published', '2026-08-08', '2026-08-09'),
    (2, 2, 'Randonnée au Fouta-Djalon', 'Circuit nature avec cascades, villages et points de vue.', 4, 8, 1850000, 'published', '2026-09-10', '2026-09-13');

INSERT INTO bookings (tour_id, customer_id, participants_count, status, total_amount) VALUES
    (1, 3, 2, 'confirmed', 1700000);

INSERT INTO payments (booking_id, provider, provider_reference, amount, status, paid_at) VALUES
    (1, 'demo-cash', 'DEMO-PAY-0001', 1700000, 'paid', datetime('now'));

INSERT INTO reviews (tour_id, customer_id, rating, comment) VALUES
    (1, 3, 5, 'Très belle expérience de démonstration.');
