select 
    move_id,
    move_type_id,
    move_name,
    move_type,
    move_accuracy,
    move_power_points,
    move_power,
    damage_class_name
from {{ ref('stg_moves') }} 
