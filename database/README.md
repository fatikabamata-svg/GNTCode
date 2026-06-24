# Base de données MySQL — Guinea National Tour

Ce dossier contient la configuration de base de données pour **Guinea National Tour**.
Le modèle cible MySQL reprend les tables officielles du projet : catégories, régions,
destinations, images, utilisateurs et réservations.

## Contenu

- `migrations/001_initial_schema.sql` : schéma MySQL complet avec clés étrangères et index.
- `seeds/001_demo_data.sql` : données initiales pour les catégories, régions et destinations fournies dans l'extrait officiel.
- `data/destinations.json` : fichier JSON source utilisé par l'importeur. Il contient l'extrait validé et peut être complété avec les 23 destinations.
- `importers/import_destinations.py` : importeur Python idempotent pour charger ou mettre à jour les destinations depuis le JSON.
- `docs/data-model.md` : documentation fonctionnelle du modèle relationnel.

## Installation rapide MySQL

```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS gnt CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p gnt < database/migrations/001_initial_schema.sql
mysql -u root -p gnt < database/seeds/001_demo_data.sql
```

## Import via Python

Installez d'abord le connecteur MySQL si nécessaire :

```bash
python -m pip install mysql-connector-python
```

Puis lancez l'import :

```bash
python database/importers/import_destinations.py \
  --host 127.0.0.1 \
  --port 3306 \
  --database gnt \
  --user root \
  --file database/data/destinations.json
```

Le script demande le mot de passe si `--password` n'est pas fourni. Il utilise
`ON DUPLICATE KEY UPDATE`, donc il peut être relancé après enrichissement du fichier JSON.

## Notes sur les 23 destinations

L'extrait technique actuellement disponible contient 4 destinations officielles. Le fichier
`database/data/destinations.json` est donc livré avec ces 4 enregistrements et peut recevoir
les 19 restantes dès que la liste complète est fournie, sans changement de schéma.
