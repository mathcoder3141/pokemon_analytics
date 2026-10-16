with source as (

    select * from {{ source('pokemon', 'raw_moves') }}
    
)

select * from source