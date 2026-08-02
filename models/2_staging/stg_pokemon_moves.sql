select 
    pokemon_id,
    move_id,
    json_extract_string(move_json, '$.move.name') as move_name,
    json_extract_string(move_json, '$.move.url') as move_url
from {{ ref('incoming_pokemon_moves') }} 
