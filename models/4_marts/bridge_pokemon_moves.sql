select
    pokemon_id,
    move_id,
    version_group,
    learn_method,
    level_learned_at
from {{ ref('int_pokemon_moves') }}
