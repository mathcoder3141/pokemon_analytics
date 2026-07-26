import requests

url = "https://pokeapi.co/api/v2/pokemon/"

all_pokemon = []

while url:
    response = requests.get(url)
    response.raise_for_status()

    data = response.json()

    all_pokemon.extend(data["results"])

    url = data["next"]

for pokemon in all_pokemon:
    pokemon_name = pokemon['name']
    pokemon_url = pokemon['url']
    pokemon_details = requests.get(
        pokemon["url"]
    ).json()
