with

pokemon_abilities as (

    select * from {{ ref('stg_pokemon_abilities') }}

),

final as (

    select
        pokemon_id,
        ability_id,
        ability_name,
        ability_url,
        is_hidden,
        slot
    from pokemon_abilities
)

select * from final

