with pokemon_stats as (

    select * from {{ ref('stg_pokemon_stats') }}

),

pokemon_stat_pivoted as (

    select
        pokemon_stats.pokemon_id,
        
        max(
            case
                when stat_name = 'hp'
                then base_stat 
            end
        ) as hp,
        
        max(
            case
                when stat_name = 'attack'
                then base_stat
            end
        ) as attack,
        
        max(
            case
                when stat_name = 'special-attack'
                then base_stat
            end
        ) as special_attack,
        
        max(
            case
                when stat_name = 'defense'
                then base_stat
            end
        ) as defense,
        
        max(
            case
                when stat_name = 'special-defense'
                then base_stat
            end 
        ) as special_defense,
        
        max(
            case
                when stat_name = 'speed'
                then base_stat
            end 
        ) as speed
    from pokemon_stats
    group by 1

),

pokemon_stat_total as (

    select
        pokemon_id,
        sum(base_stat) as base_stat_total
    from pokemon_stats
    group by 1
)

select
    pokemon_stat_pivoted.pokemon_id,
    pokemon_stat_pivoted.hp,
    pokemon_stat_pivoted.attack,
    pokemon_stat_pivoted.special_attack,
    pokemon_stat_pivoted.defense,
    pokemon_stat_pivoted.special_defense,
    pokemon_stat_pivoted.speed,
    pokemon_stat_total.base_stat_total
from pokemon_stat_pivoted
inner join pokemon_stat_total
    on pokemon_stat_pivoted.pokemon_id = pokemon_stat_total.pokemon_id
