# Base de données de l'application Solide

Ce dossier fournit une première base relationnelle pour l'application **Solide** de Guinea National Tour. Le schéma est écrit en SQL compatible SQLite afin de démarrer rapidement en local, tout en restant simple à porter vers PostgreSQL ou MySQL.

## Contenu

- `migrations/001_initial_schema.sql` : tables principales, contraintes d'intégrité et index.
- `seeds/001_demo_data.sql` : données de démonstration pour tester l'application.
- `docs/data-model.md` : explication fonctionnelle du modèle de données.

## Installation locale rapide

```bash
sqlite3 solide.db < database/migrations/001_initial_schema.sql
sqlite3 solide.db < database/seeds/001_demo_data.sql
sqlite3 solide.db "PRAGMA foreign_keys = ON; SELECT name FROM sqlite_master WHERE type='table';"
```

## Tables principales

- `users` : comptes clients, guides et administrateurs.
- `destinations` : lieux touristiques proposés.
- `tours` : circuits et expériences rattachés à une destination.
- `bookings` : réservations clients.
- `payments` : paiements liés aux réservations.
- `reviews` : avis clients sur les circuits.

## Notes de production

Avant une mise en production, remplacez les mots de passe de démonstration par des hash générés par l'application, configurez une vraie stratégie de migrations et vérifiez le moteur de base de données cible.
