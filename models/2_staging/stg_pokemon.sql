select 
    id as pokemon_id,
    "name",
    cast(raw_json.base_experience as integer) as base_experience,
    cast(raw_json.height as integer) as height,

    cast(
        split_part(
            json_extract_string(raw_json, '$.species.url'),
            '/',
            -2
        ) as integer
    ) as species_id,

    cast(raw_json.weight as integer) as "weight"
from {{ ref('incoming_pokemon') }}
