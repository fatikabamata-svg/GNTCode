# Modèle de données Solide

## Vue d'ensemble

La base de données couvre le parcours principal d'une application de tourisme : publication de destinations, création de circuits, réservation par un client, paiement et avis après l'expérience.

## Relations

- Un `user` peut être client, guide ou administrateur grâce au champ `role`.
- Une `destination` possède plusieurs `tours`.
- Un `tour` appartient à une `destination` et peut être animé par un guide (`users.role = 'guide'`).
- Une `booking` relie un client à un circuit et conserve le nombre de participants, le statut et le montant total.
- Un `payment` est rattaché à une réservation.
- Une `review` est unique par couple circuit/client pour éviter plusieurs avis du même client sur le même circuit.

## Statuts métier

| Table | Champ | Valeurs |
| --- | --- | --- |
| `users` | `role` | `customer`, `guide`, `admin` |
| `tours` | `status` | `draft`, `published`, `archived` |
| `bookings` | `status` | `pending`, `confirmed`, `cancelled`, `completed` |
| `payments` | `status` | `initiated`, `paid`, `failed`, `refunded` |

## Évolutions possibles

- Ajouter une table `tour_images` pour gérer une galerie de photos.
- Ajouter une table `availability_slots` si les dates de départ deviennent récurrentes.
- Ajouter une table `audit_logs` pour tracer les actions administratives.
- Migrer vers PostgreSQL si l'application nécessite une concurrence élevée, des vues matérialisées ou des recherches avancées.
