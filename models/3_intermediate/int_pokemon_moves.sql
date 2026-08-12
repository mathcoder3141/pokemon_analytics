with 

raw_pokemon_moves as (

    select * from {{ ref('incoming_pokemon_moves') }}

),

version_group_details as (
    
    select 

        raw_pokemon_moves.pokemon_id,
        raw_pokemon_moves.move_id,

        json_extract_string(
            version_group.value,
            '$.move_learn_method.name'
        ) as learn_method,

        cast(
            json_extract(
                version_group.value,
                '$.level_learned_at'
            ) as integer
        ) as level_learned_at,

        json_extract_string(
            version_group.value,
            '$.version_group.name'
        ) as version_group

    from raw_pokemon_moves,
    json_each(
        move_json,
        '$.version_group_details'
    ) as version_group

)

select
    stg_pokemon_moves.pokemon_id,
    stg_pokemon_moves.move_id,
    stg_pokemon_moves.move_name,
    stg_pokemon_moves.move_url,
    version_group_details.learn_method,
    version_group_details.level_learned_at,
    version_group_details.version_group
from {{ ref('stg_pokemon_moves') }} as stg_pokemon_moves
left join version_group_details
    on stg_pokemon_moves.pokemon_id = version_group_details.pokemon_id
    and stg_pokemon_moves.move_id = version_group_details.move_id
