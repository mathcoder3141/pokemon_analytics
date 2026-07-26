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
    CREATE TABLE raw_pokemon (
        id INTEGER PRIMARY KEY,
        name VARCHAR,
        raw_json JSON,
        loaded_at TIMESTAMPTZ,
        source_url VARCHAR
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
        source_url = pokemon["url"]
        
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

def main(): 
    with duckdb.connect('pokemon.duckdb') as poke_db:
        pokemon_index = get_pokemon_index()
        create_raw_table(poke_db)
        load_raw_pokemon(poke_db, pokemon_index)

if __name__ == "__main__":
    main()