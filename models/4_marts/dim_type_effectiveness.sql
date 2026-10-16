select
    attacking_type.type_id as attacking_type_id,
    attacking_type.type_name as attacking_type_name,
    defending_type.type_id  as defending_type_id,
    defending_type.type_name as defending_type_name,
    coalesce(damage_relations.multiplier, 1.0) as multiplier
from {{ ref('stg_types') }} as attacking_type
cross join {{ ref('stg_types') }} as defending_type
left join {{ ref('int_type_damage_relations') }} as damage_relations
    on damage_relations.attacking_type_id = attacking_type.type_id
    and damage_relations.defending_type_name  = defending_type.type_name