with source as (
    
    select * from {{ source('pokemon', 'raw_pokemon_abilities') }}

)

select * from source
