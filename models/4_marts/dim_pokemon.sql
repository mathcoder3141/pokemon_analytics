select 
    pokemon_id,
    "name",
    base_experience,
    species_id,
    height,
    "weight"
from {{ ref('stg_pokemon') }}
