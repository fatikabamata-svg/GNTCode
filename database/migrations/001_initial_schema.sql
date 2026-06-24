-- Initial relational schema for the Solide application.
-- Target engine: SQLite 3.35+ with foreign keys enabled.
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'guide', 'admin')),
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS destinations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    region TEXT NOT NULL,
    country TEXT NOT NULL DEFAULT 'Guinée',
    description TEXT,
    latitude REAL,
    longitude REAL,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS tours (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    destination_id INTEGER NOT NULL,
    guide_id INTEGER,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    duration_days INTEGER NOT NULL CHECK (duration_days > 0),
    capacity INTEGER NOT NULL CHECK (capacity > 0),
    price_amount INTEGER NOT NULL CHECK (price_amount >= 0),
    currency TEXT NOT NULL DEFAULT 'GNF',
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
    starts_on TEXT,
    ends_on TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE RESTRICT,
    FOREIGN KEY (guide_id) REFERENCES users(id) ON DELETE SET NULL,
    CHECK (ends_on IS NULL OR starts_on IS NULL OR ends_on >= starts_on)
);

CREATE TABLE IF NOT EXISTS bookings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tour_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    participants_count INTEGER NOT NULL DEFAULT 1 CHECK (participants_count > 0),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
    total_amount INTEGER NOT NULL CHECK (total_amount >= 0),
    currency TEXT NOT NULL DEFAULT 'GNF',
    booked_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (tour_id) REFERENCES tours(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    booking_id INTEGER NOT NULL,
    provider TEXT NOT NULL,
    provider_reference TEXT UNIQUE,
    amount INTEGER NOT NULL CHECK (amount >= 0),
    currency TEXT NOT NULL DEFAULT 'GNF',
    status TEXT NOT NULL DEFAULT 'initiated' CHECK (status IN ('initiated', 'paid', 'failed', 'refunded')),
    paid_at TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tour_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    UNIQUE (tour_id, customer_id),
    FOREIGN KEY (tour_id) REFERENCES tours(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_tours_destination_id ON tours(destination_id);
CREATE INDEX IF NOT EXISTS idx_tours_guide_id ON tours(guide_id);
CREATE INDEX IF NOT EXISTS idx_tours_status ON tours(status);
CREATE INDEX IF NOT EXISTS idx_bookings_tour_id ON bookings(tour_id);
CREATE INDEX IF NOT EXISTS idx_bookings_customer_id ON bookings(customer_id);
CREATE INDEX IF NOT EXISTS idx_payments_booking_id ON payments(booking_id);
CREATE INDEX IF NOT EXISTS idx_reviews_tour_id ON reviews(tour_id);
