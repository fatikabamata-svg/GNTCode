# Modèle de données — Guinea National Tour

Le modèle relationnel est conçu pour alimenter le site web, l'application mobile et les routes API prévues :

- `GET /api/v1/destinations`
- `GET /api/v1/destinations/{id}`
- `POST /api/v1/reservations`

## Tables

### `categories`

Regroupe les destinations par familles touristiques : îles et plages, nature et montagnes, villes et patrimoine, réserves et biodiversité.

Champs clés :

- `name` : libellé affiché.
- `slug` : identifiant stable pour l'API et les URLs.
- `description` : texte éditorial optionnel.

### `regions`

Référence les grandes zones géographiques utilisées pour filtrer les destinations.

Champs clés :

- `name` : nom de la région ou zone touristique.
- `description` : résumé éditorial.

### `destinations`

Table centrale du projet. Elle contient les fiches touristiques affichées sur le web et le mobile.

Champs clés :

- `name`, `slug` : identité publique de la destination.
- `short_description`, `long_description` : contenus de présentation.
- `destination_type` : type fourni par les données sources, par exemple `île`, `ville` ou `réserve / montagne`.
- `region_id`, `category_id` : rattachements relationnels.
- `prefecture`, `locality` : localisation administrative et locale.
- `latitude`, `longitude`, `google_maps_url` : données cartographiques optionnelles.
- `best_season`, `access_level`, `entry_fee` : informations pratiques.
- `source_url`, `image_url`, `image_credit` : traçabilité et médias.
- `verification_status` : statut éditorial, par exemple `pending` ou `verified`.
- `is_featured`, `is_active` : contrôle d'affichage.

### `destination_images`

Stocke une ou plusieurs images par destination.

Champs clés :

- `destination_id` : destination parente.
- `image_url` : URL de l'image.
- `caption`, `credit`, `source_url` : métadonnées éditoriales.
- `is_primary` : image principale pour la carte ou la fiche.

### `users`

Contient les futurs comptes utilisateurs ou administrateurs.

Champs clés :

- `full_name`, `email`, `phone` : identité et contact.
- `password_hash` : hash applicatif, jamais un mot de passe en clair.
- `role` : rôle fonctionnel, par défaut `user`.

### `reservations`

Contient les demandes de réservation créées depuis l'API.

Champs clés :

- `user_id` : utilisateur rattaché, facultatif pour permettre des demandes invitées.
- `destination_id` : destination concernée.
- `booking_type` : type de demande, par exemple visite, circuit ou information.
- `booking_date`, `travel_date` : dates de demande et de voyage.
- `travelers_count` : nombre de voyageurs.
- `status` : état de traitement, par défaut `pending`.
- `notes` : message libre.

## Stratégie d'import

Deux chemins sont disponibles :

1. Import SQL direct avec `database/seeds/001_demo_data.sql`.
2. Import dynamique avec `database/importers/import_destinations.py` et `database/data/destinations.json`.

L'importeur Python est recommandé pour la liste complète des 23 destinations, car il permet de relancer la synchronisation après correction ou enrichissement du JSON.
