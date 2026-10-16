select 
    id as move_id,
    json_extract_string(raw_json, '$.name') as move_name,
    json_extract_string(raw_json, '$.type.name') as move_type,
    cast(json_extract(raw_json, '$.accuracy') as integer) as move_accuracy,
    cast(json_extract(raw_json, '$.pp') as integer) as move_power_points,
    cast(json_extract(raw_json, '$.power') as integer) as move_power,
    json_extract_string(raw_json, '$.damage_class.name') as damage_class_name,
        cast(
        split_part(
            json_extract_string(raw_json, '$.type.url'),
            '/',
            -2
        ) as integer
    ) as move_type_id,
from {{ ref('incoming_moves') }} 
