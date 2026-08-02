with source as (
    
    select * from {{ source('pokemon', 'raw_pokemon') }}

)

select * from source
