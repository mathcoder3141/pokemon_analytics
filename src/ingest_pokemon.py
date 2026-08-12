import duckdb
import requests
import json
from datetime import datetime, timezone

def get_pokemon_index():
    """
    Queries the Pokemon endpoint of PokeAPI and returns
    a list containing all available Pokemon records.
    Handles API pagination through the `next` response key.
    """

    url = "https://pokeapi.co/api/v2/pokemon/"
    all_pokemon = []
    while url:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        all_pokemon.extend(data["results"])
        url = data["next"]

    return all_pokemon

def create_raw_table(conn):
    """
    Creates the raw Pokemon table in DuckDB.
    Drops any existing table to perform a full refresh.
    """

    conn.execute(
        """
        DROP TABLE IF EXISTS raw_pokemon;
        """
    )

    conn.execute(
        """
        DROP TABLE IF EXISTS raw_pokemon_moves;
        """
    )

    conn.execute(
        """
        DROP TABLE IF EXISTS raw_pokemon_abilities;
        """
    )

    conn.execute(
        """
        DROP TABLE IF EXISTS raw_pokemon_stats;
        """
    )

    conn.execute(
        """
        DROP TABLE IF EXISTS raw_pokemon_types;
        """
    )

    conn.execute(
        """
        DROP TABLE IF EXISTS raw_pokemon_species;
        """
    )

    conn.execute(
        """
        CREATE TABLE raw_pokemon (
            id INTEGER PRIMARY KEY,
            name VARCHAR,
            raw_json JSON,
            loaded_at TIMESTAMPTZ,
            source_url VARCHAR
        );
        """
    )

    conn.execute(
        """
        CREATE TABLE raw_pokemon_moves (
            pokemon_id INTEGER,
            move_id INTEGER,
            move_json JSON,
            loaded_at TIMESTAMPTZ,
            PRIMARY KEY (pokemon_id, move_id)
        );
        """
    )

    conn.execute(
        """
        CREATE TABLE raw_pokemon_abilities (
            pokemon_id INTEGER,
            ability_id INTEGER,
            ability_json JSON,
            loaded_at TIMESTAMPTZ,
            PRIMARY KEY (pokemon_id, ability_id)
        );
        """
    )

    conn.execute(
        """
        CREATE TABLE raw_pokemon_stats (
            pokemon_id INTEGER,
            stat_id INTEGER,
            stat_json JSON,
            loaded_at TIMESTAMPTZ,
            PRIMARY KEY (pokemon_id, stat_id)
        );
        """
    )

    conn.execute(
        """
        CREATE TABLE raw_pokemon_types (
            pokemon_id INTEGER,
            type_id INTEGER,
            type_json JSON,
            loaded_at TIMESTAMPTZ,
            PRIMARY KEY (pokemon_id, type_id)
        );
        """
    )

    conn.execute(
        """
        CREATE TABLE raw_pokemon_species (
            pokemon_id INTEGER,
            species_id INTEGER,
            species_json JSON,
            loaded_at TIMESTAMPTZ,
            source_url VARCHAR,
            PRIMARY KEY (pokemon_id, species_id)
        );
        """
    )

def load_raw_pokemon(conn, pokemon_index):
    """
    Retrieves detailed Pokemon records from PokeAPI
    and loads raw JSON responses into DuckDB.
    """
    loaded_at = datetime.now(timezone.utc)
    total = len(pokemon_index)

    session = requests.Session()

    for index, pokemon in enumerate(pokemon_index, start=1):
        print(f"Loading {index}/{total}: {pokemon['name']}")

        detail_response = session.get(pokemon["url"], timeout = 30)
        detail_response.raise_for_status()
        pokemon_details = detail_response.json()

        pokemon_id = pokemon_details['id']
        pokemon_name = pokemon_details['name']
        species_url = pokemon_details['species']['url']
        species_response = session.get(species_url, timeout = 30)
        species_response.raise_for_status()
        species_details = species_response.json()
        species_id = species_url.rstrip("/").split("/")[-1]
        source_url = pokemon["url"]

        pokemon_moves = pokemon_details['moves']
        pokemon_abilities = pokemon_details['abilities']
        pokemon_stats = pokemon_details['stats']
        pokemon_types = pokemon_details['types']

        conn.execute(
            """
            INSERT INTO raw_pokemon (
                id,
                name,
                raw_json,
                loaded_at,
                source_url
            )
            VALUES (?, ?, ?, ?, ?)
            """, (pokemon_id, pokemon_name, json.dumps(pokemon_details), loaded_at, source_url)
        )

        conn.execute(
            """
            INSERT INTO raw_pokemon_species (
                pokemon_id,
                species_id,
                species_json,
                loaded_at,
                source_url
            )
            VALUES (?, ?, ?, ?, ?)
            """, (pokemon_id, species_id, json.dumps(species_details), loaded_at, species_url)
        )


        for move in pokemon_moves:
            move_url = move["move"]["url"]

            move_id = move_url.rstrip("/").split("/")[-1]
            conn.execute(
                """
                INSERT INTO raw_pokemon_moves (
                    pokemon_id,
                    move_id,
                    move_json,
                    loaded_at
                )
                VALUES (?, ?, ?, ?)
                """, (pokemon_id, move_id, json.dumps(move), loaded_at)
            )

        for ability in pokemon_abilities:
            ability_url = ability["ability"]["url"]

            ability_id = ability_url.rstrip("/").split("/")[-1]
            conn.execute(
                """
                INSERT INTO raw_pokemon_abilities (
                    pokemon_id,
                    ability_id,
                    ability_json,
                    loaded_at
                )
                VALUES (?, ?, ?, ?)
                """, (pokemon_id, ability_id, json.dumps(ability), loaded_at)
            )

        for typ in pokemon_types:
            type_url = typ["type"]["url"]

            type_id = type_url.rstrip("/").split("/")[-1]
            conn.execute(
                """
                INSERT INTO raw_pokemon_types (
                    pokemon_id,
                    type_id,
                    type_json,
                    loaded_at
                )
                VALUES (?, ?, ?, ?)
                """, (pokemon_id, type_id, json.dumps(typ), loaded_at)
            )

        for stat in pokemon_stats:
            stat_url = stat["stat"]["url"]

            stat_id = stat_url.rstrip("/").split("/")[-1]
            conn.execute(
                """
                INSERT INTO raw_pokemon_stats (
                    pokemon_id,
                    stat_id,
                    stat_json,
                    loaded_at
                )
                VALUES (?, ?, ?, ?)
                """, (pokemon_id, stat_id, json.dumps(stat), loaded_at)
            )

def main():
    with duckdb.connect('pokemon.duckdb') as poke_db:
        pokemon_index = get_pokemon_index()
        create_raw_table(poke_db)
        load_raw_pokemon(poke_db, pokemon_index)

if __name__ == "__main__":
    main()
