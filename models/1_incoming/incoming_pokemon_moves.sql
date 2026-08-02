with source as (
    
    select * from {{ source('pokemon', 'raw_pokemon_moves') }}

)

select * from source
