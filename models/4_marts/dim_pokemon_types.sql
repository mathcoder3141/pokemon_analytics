with pokemon_types as (

    select * from {{ ref('stg_pokemon_types') }}
)

select
    pokemon_id,
    max(type_id) filter (where slot = 1) as primary_type_id,
    max(type_id) filter (where slot = 2) as secondary_type_id,

    max(type_name) filter (where slot = 1) as primary_type_name,
    max(type_name) filter (where slot = 2) as secondary_type_name
from pokemon_types
group by 1