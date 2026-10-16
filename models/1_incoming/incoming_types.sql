with source as (

    select * from {{ source('pokemon', 'raw_types') }}
    
)

select * from source