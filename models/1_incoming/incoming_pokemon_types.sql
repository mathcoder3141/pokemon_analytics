with source as (
    
    select * from {{ source('pokemon', 'raw_pokemon_types') }}

)

select * from source
