# GNTCode

Projets de développement et d'analyse pour Guinea National Tour.

## Application Solide

Une première base de données pour l'application **Solide** est disponible dans le dossier [`database`](database/README.md). Elle contient :

- une migration SQL initiale compatible SQLite ;
- un jeu de données de démonstration ;
- une documentation du modèle de données.

Pour créer une base locale :

```bash
sqlite3 solide.db < database/migrations/001_initial_schema.sql
sqlite3 solide.db < database/seeds/001_demo_data.sql
```
