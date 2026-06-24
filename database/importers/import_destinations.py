#!/usr/bin/env python3
"""Import Guinea National Tour destinations into MySQL.

Usage example:
    python database/importers/import_destinations.py \
        --host 127.0.0.1 --port 3306 --database gnt \
        --user gnt_user --password secret \
        --file database/data/destinations.json

The JSON file may contain the 4 official extract records now, or the full 23
records later. Existing categories, regions and destinations are updated by
unique name/slug keys so the importer can be safely re-run.
"""

from __future__ import annotations

import argparse
import getpass
import json
from pathlib import Path
from typing import Any

try:
    import mysql.connector
    from mysql.connector import MySQLConnection
except ImportError as exc:  # pragma: no cover - depends on local environment
    raise SystemExit(
        "Missing dependency: install mysql-connector-python with "
        "`python -m pip install mysql-connector-python`."
    ) from exc

DEFAULT_CATEGORIES = {
    "île": ("Îles et plages", "iles-et-plages", "Destinations côtières, îles, plages et excursions maritimes."),
    "plateau / région": ("Nature et montagnes", "nature-et-montagnes", "Plateaux, montagnes, cascades, réserves et sites naturels."),
    "ville": ("Villes et patrimoine", "villes-et-patrimoine", "Villes, quartiers historiques, culture urbaine et patrimoine."),
    "réserve / montagne": ("Réserves et biodiversité", "reserves-et-biodiversite", "Aires naturelles, faune, flore et biodiversité remarquable."),
}

REGION_DESCRIPTIONS = {
    "Boké": "Région maritime et minière du nord-ouest de la Guinée.",
    "Moyenne Guinée": "Région de plateaux, vallées, cascades et paysages du Fouta Djallon.",
    "Conakry": "Capitale de la Guinée, centre administratif, économique et culturel.",
    "Guinée forestière": "Région forestière du sud-est, connue pour sa biodiversité et ses reliefs.",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Import destinations into the Guinea National Tour MySQL database.")
    parser.add_argument("--host", default="127.0.0.1", help="MySQL host")
    parser.add_argument("--port", type=int, default=3306, help="MySQL port")
    parser.add_argument("--database", required=True, help="MySQL database name")
    parser.add_argument("--user", required=True, help="MySQL user")
    parser.add_argument("--password", help="MySQL password. If omitted, an interactive prompt is shown.")
    parser.add_argument("--file", default="database/data/destinations.json", help="Path to destinations JSON file")
    return parser.parse_args()


def load_destinations(path: Path) -> list[dict[str, Any]]:
    with path.open("r", encoding="utf-8") as file_handle:
        data = json.load(file_handle)
    if not isinstance(data, list):
        raise ValueError("The destinations file must contain a JSON array.")
    for index, item in enumerate(data, start=1):
        if not isinstance(item, dict):
            raise ValueError(f"Destination #{index} must be a JSON object.")
        for key in ("name", "slug", "type", "region"):
            if not item.get(key):
                raise ValueError(f"Destination #{index} is missing required key: {key}")
    return data


def upsert_category(connection: MySQLConnection, name: str, slug: str, description: str | None) -> int:
    with connection.cursor() as cursor:
        cursor.execute(
            """
            INSERT INTO categories (name, slug, description)
            VALUES (%s, %s, %s)
            ON DUPLICATE KEY UPDATE
                name = VALUES(name),
                description = VALUES(description),
                id = LAST_INSERT_ID(id)
            """,
            (name, slug, description),
        )
        return int(cursor.lastrowid)


def upsert_region(connection: MySQLConnection, name: str, description: str | None) -> int:
    with connection.cursor() as cursor:
        cursor.execute(
            """
            INSERT INTO regions (name, description)
            VALUES (%s, %s)
            ON DUPLICATE KEY UPDATE
                description = VALUES(description),
                id = LAST_INSERT_ID(id)
            """,
            (name, description),
        )
        return int(cursor.lastrowid)


def upsert_destination(connection: MySQLConnection, destination: dict[str, Any], region_id: int, category_id: int) -> int:
    short_description = destination.get("shortDescription") or destination.get("short_description")
    long_description = destination.get("longDescription") or destination.get("long_description")
    source_url = destination.get("sourceUrl") or destination.get("source_url")
    google_maps_url = destination.get("googleMapsUrl") or destination.get("google_maps_url")
    image_url = destination.get("imageUrl") or destination.get("image_url")
    image_credit = destination.get("imageCredit") or destination.get("image_credit")
    verification_status = destination.get("status") or destination.get("verification_status") or "pending"
    is_featured = bool(destination.get("featured", destination.get("is_featured", False)))

    with connection.cursor() as cursor:
        cursor.execute(
            """
            INSERT INTO destinations (
                name, slug, short_description, long_description, destination_type,
                region_id, category_id, prefecture, locality, latitude, longitude,
                google_maps_url, best_season, access_level, entry_fee, source_url,
                image_url, image_credit, verification_status, is_featured, is_active
            ) VALUES (
                %s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s
            )
            ON DUPLICATE KEY UPDATE
                name = VALUES(name),
                short_description = VALUES(short_description),
                long_description = VALUES(long_description),
                destination_type = VALUES(destination_type),
                region_id = VALUES(region_id),
                category_id = VALUES(category_id),
                prefecture = VALUES(prefecture),
                locality = VALUES(locality),
                latitude = VALUES(latitude),
                longitude = VALUES(longitude),
                google_maps_url = VALUES(google_maps_url),
                best_season = VALUES(best_season),
                access_level = VALUES(access_level),
                entry_fee = VALUES(entry_fee),
                source_url = VALUES(source_url),
                image_url = VALUES(image_url),
                image_credit = VALUES(image_credit),
                verification_status = VALUES(verification_status),
                is_featured = VALUES(is_featured),
                is_active = VALUES(is_active),
                id = LAST_INSERT_ID(id)
            """,
            (
                destination["name"],
                destination["slug"],
                short_description,
                long_description,
                destination.get("type") or destination.get("destination_type"),
                region_id,
                category_id,
                destination.get("prefecture"),
                destination.get("locality"),
                destination.get("latitude"),
                destination.get("longitude"),
                google_maps_url,
                destination.get("bestSeason") or destination.get("best_season"),
                destination.get("accessLevel") or destination.get("access_level"),
                destination.get("entryFee") or destination.get("entry_fee"),
                source_url,
                image_url,
                image_credit,
                verification_status,
                is_featured,
                bool(destination.get("active", destination.get("is_active", True))),
            ),
        )
        destination_id = int(cursor.lastrowid)

    images = destination.get("images") or []
    for image in images:
        upsert_destination_image(connection, destination_id, image)

    return destination_id


def upsert_destination_image(connection: MySQLConnection, destination_id: int, image: dict[str, Any]) -> None:
    image_url = image.get("imageUrl") or image.get("image_url")
    if not image_url:
        return
    with connection.cursor() as cursor:
        cursor.execute(
            """
            INSERT INTO destination_images (destination_id, image_url, caption, credit, source_url, is_primary)
            VALUES (%s, %s, %s, %s, %s, %s)
            """,
            (
                destination_id,
                image_url,
                image.get("caption"),
                image.get("credit"),
                image.get("sourceUrl") or image.get("source_url"),
                bool(image.get("primary", image.get("is_primary", False))),
            ),
        )


def category_for(destination: dict[str, Any]) -> tuple[str, str, str | None]:
    explicit_category = destination.get("category")
    if explicit_category:
        slug = destination.get("categorySlug") or destination.get("category_slug") or slugify(explicit_category)
        return explicit_category, slug, destination.get("categoryDescription") or destination.get("category_description")
    return DEFAULT_CATEGORIES.get(
        destination.get("type"),
        ("Autres destinations", "autres-destinations", "Autres sites touristiques et expériences à classifier."),
    )


def slugify(value: str) -> str:
    replacements = str.maketrans({"Î": "I", "î": "i", "é": "e", "è": "e", "ê": "e", "à": "a", "ç": "c", "ù": "u", "’": "-"})
    return "-".join(value.translate(replacements).lower().split())


def main() -> None:
    args = parse_args()
    password = args.password if args.password is not None else getpass.getpass("MySQL password: ")
    destinations = load_destinations(Path(args.file))

    connection = mysql.connector.connect(
        host=args.host,
        port=args.port,
        database=args.database,
        user=args.user,
        password=password,
        charset="utf8mb4",
        collation="utf8mb4_unicode_ci",
    )

    try:
        imported = 0
        for destination in destinations:
            category_name, category_slug, category_description = category_for(destination)
            category_id = upsert_category(connection, category_name, category_slug, category_description)
            region_name = destination["region"]
            region_id = upsert_region(connection, region_name, REGION_DESCRIPTIONS.get(region_name))
            upsert_destination(connection, destination, region_id, category_id)
            imported += 1
        connection.commit()
        print(f"Imported {imported} destinations into {args.database}.")
    except Exception:
        connection.rollback()
        raise
    finally:
        connection.close()


if __name__ == "__main__":
    main()
