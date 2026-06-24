-- Guinea National Tour - MySQL initial schema
-- Target engine: MySQL 8.0+ / MariaDB 10.5+
-- Charset: utf8mb4 for French and Guinean place names.

SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE,
    slug VARCHAR(140) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS regions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS destinations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    slug VARCHAR(220) NOT NULL UNIQUE,
    short_description TEXT,
    long_description TEXT,
    destination_type VARCHAR(120),
    region_id INT NULL,
    category_id INT NULL,
    prefecture VARCHAR(120),
    locality VARCHAR(180),
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    google_maps_url TEXT,
    best_season VARCHAR(120),
    access_level VARCHAR(80),
    entry_fee VARCHAR(80),
    source_url TEXT,
    image_url TEXT,
    image_credit VARCHAR(255),
    verification_status VARCHAR(40) DEFAULT 'pending',
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_dest_region FOREIGN KEY (region_id) REFERENCES regions(id) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_dest_category FOREIGN KEY (category_id) REFERENCES categories(id) ON UPDATE CASCADE ON DELETE SET NULL,
    INDEX idx_destinations_region_id (region_id),
    INDEX idx_destinations_category_id (category_id),
    INDEX idx_destinations_slug (slug),
    INDEX idx_destinations_featured_active (is_featured, is_active),
    INDEX idx_destinations_status (verification_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS destination_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    destination_id INT NOT NULL,
    image_url TEXT NOT NULL,
    caption TEXT,
    credit VARCHAR(255),
    source_url TEXT,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_img_destination FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE CASCADE,
    INDEX idx_destination_images_destination_id (destination_id),
    INDEX idx_destination_images_primary (destination_id, is_primary)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(180) NOT NULL,
    email VARCHAR(180) UNIQUE,
    phone VARCHAR(60),
    password_hash TEXT,
    role VARCHAR(40) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_users_email (email),
    INDEX idx_users_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS reservations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    destination_id INT NULL,
    booking_type VARCHAR(60) NOT NULL,
    booking_date DATE,
    travel_date DATE,
    travelers_count INT DEFAULT 1,
    status VARCHAR(40) DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_res_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_res_destination FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE SET NULL,
    INDEX idx_reservations_user_id (user_id),
    INDEX idx_reservations_destination_id (destination_id),
    INDEX idx_reservations_status (status),
    INDEX idx_reservations_travel_date (travel_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
