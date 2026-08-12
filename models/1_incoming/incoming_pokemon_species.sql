with source as (
    
    select * from {{ source('pokemon', 'raw_pokemon_species') }}

)

select * from source
