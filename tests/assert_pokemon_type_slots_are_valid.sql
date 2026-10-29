select
    pokemon_id
from {{ ref('stg_pokemon_types') }}
group by 1
having count(case when slot = 1 then 1 end) != 1
    or count(case when slot = 2 then 1 end) > 1
    or count(case when slot not in (1, 2) or slot is null then 1 end) > 0
