# API Backend — Guinea National Tour

API Node.js/Express connectée à MySQL pour exposer les destinations et enregistrer les demandes de réservation.

## Routes disponibles

- `GET /api/v1/health` : vérifie que l'API répond et que MySQL est joignable.
- `GET /api/v1/destinations` : liste les destinations actives avec filtres optionnels.
- `POST /api/v1/reservations` : crée une demande de réservation voyageur.

## Installation

```bash
cd backend
npm install
cp .env.example .env
npm run start
```

La base MySQL doit avoir été initialisée avec :

```bash
mysql -u root -p gnt < ../database/migrations/001_initial_schema.sql
mysql -u root -p gnt < ../database/seeds/001_demo_data.sql
```

## GET `/api/v1/destinations`

Filtres optionnels :

- `region` : nom ou partie du nom de la région.
- `category` : nom ou slug de catégorie.
- `status` : statut de vérification, par exemple `verified`.
- `featured` : `true` ou `false`.
- `active` : `true` ou `false`, `true` par défaut.
- `search` : recherche textuelle simple.
- `limit` et `offset` : pagination.

Exemple :

```bash
curl "http://localhost:3000/api/v1/destinations?region=Conakry&featured=true"
```

## POST `/api/v1/reservations`

Exemple de payload :

```json
{
  "destinationId": 1,
  "bookingType": "visite-guidée",
  "travelDate": "2026-08-15",
  "travelersCount": 2,
  "guestFullName": "Aminata Diallo",
  "guestEmail": "aminata@example.com",
  "guestPhone": "+224620000000",
  "notes": "Nous souhaitons une visite en famille."
}
```

Exemple curl :

```bash
curl -X POST "http://localhost:3000/api/v1/reservations" \
  -H "Content-Type: application/json" \
  -d '{"destinationId":1,"bookingType":"visite-guidée","travelDate":"2026-08-15","travelersCount":2,"guestFullName":"Aminata Diallo","guestEmail":"aminata@example.com"}'
```
