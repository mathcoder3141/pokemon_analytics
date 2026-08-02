with

src as (

    select
        pokemon_id,
        ability_id,
        ability_json
    from {{ ref('incoming_pokemon_abilities') }}

),

abilities as (

    select
        pokemon_id,
    
        json_extract_string(
            ability_json,
            '$.ability.name'
        ) as ability_name,
        
        json_extract_string(
            ability_json,
            '$.ability.url'
        ) as ability_url,
        
        cast(
            json_extract(
                ability_json,
                '$.is_hidden'
            ) as boolean
        ) as is_hidden,
        
        cast(
            json_extract(
                ability_json,
                '$.slot'
            ) as integer
        ) as slot
    from src
)

select * from abilities
