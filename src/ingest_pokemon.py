import duckdb
import requests
import json
from datetime import datetime, timezone

poke_db = duckdb.connect('pokemon.duckdb')

url = "https://pokeapi.co/api/v2/pokemon/"

all_pokemon = []

while url:
    response = requests.get(url)
    response.raise_for_status()

    data = response.json()

    all_pokemon.extend(data["results"])

    url = data["next"]

poke_db.execute(
    """
    DROP TABLE IF EXISTS raw_pokemon;
    """
)

poke_db.execute(
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

loaded_at = datetime.now(timezone.utc)
total = len(all_pokemon)

for index, pokemon in enumerate(all_pokemon, start=1):
    print(f"Loading {index}/{total}: {pokemon['name']}")

    detail_response = requests.get(pokemon["url"])
    detail_response.raise_for_status()
    pokemon_details = detail_response.json()
    
    pokemon_id = pokemon_details['id']
    pokemon_name = pokemon_details['name']
    source_url = pokemon["url"]
    
    poke_db.execute(
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
    
poke_db.close()