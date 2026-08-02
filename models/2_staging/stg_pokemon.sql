select 
    id as pokemon_id,
    "name",
    cast(raw_json.base_experience as integer) as base_experience,
    cast(raw_json.height as integer) as height,
    json_extract_string(raw_json, '$.species.name') as species_name,
    json_extract_string(raw_json, '$.species.url') as species_url,
    cast(raw_json.weight as integer) as "weight"
from {{ ref('incoming_pokemon') }}
