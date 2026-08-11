
--     base_stat
--     effort
-- }

with 

src as (

    select
        pokemon_id,
        stat_id,
        stat_json
    from {{ ref('incoming_pokemon_stats') }}

),

final as (

    select
        pokemon_id,
        stat_id,
        
        json_extract_string(
            stat_json,
            '$.stat.name'
        ) as stat_name,

        cast(
            json_extract(
                stat_json,
                '$.base_stat'
            ) as integer
        ) as slot,
        
        cast(
            json_extract(
                stat_json,
                '$.effort'
            ) as integer
        ) as effort,


        json_extract_string(
            stat_json,
            '$.stat.url'
        ) as stat_url,
    from src

)

select * from final
