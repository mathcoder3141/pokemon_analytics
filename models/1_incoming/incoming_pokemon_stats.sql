with source as (
    
    select * from {{ source('pokemon', 'raw_pokemon_stats') }}

)

select * from source
