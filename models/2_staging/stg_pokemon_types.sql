with 

src as (

    select
        pokemon_id,
        type_id,
        type_json
    from {{ ref('incoming_pokemon_types') }}

),

final as (

    select
        pokemon_id,
        type_id,
        
        json_extract_string(
            type_json,
            '$.type.name'
        ) as type_name,
        
        cast(
            json_extract(
                type_json,
                '$.slot'
            ) as integer
        ) as slot,

        json_extract_string(
            type_json,
            '$.type.url'
        ) as type_url,
    from src

)

select * from final
