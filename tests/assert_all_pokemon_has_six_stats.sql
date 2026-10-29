with

pokemon_stat_completeness as (
    
    select
        pokemon.pokemon_id,
        count(distinct(pokemon_stats.stat_name)) as distinct_stat_count,
        count(distinct case when pokemon_stats.stat_name in {{ var('pokemon_stats') }} 
                then stat_name 
            end
        ) as expected_stat_count
        from {{ ref('stg_pokemon') }} as pokemon
        left join {{ ref('stg_pokemon_stats' ) }} as pokemon_stats
            on pokemon.pokemon_id = pokemon_stats.pokemon_id
        group by 1
) 

select * from pokemon_stat_completeness
where distinct_stat_count != {{ var('pokemon_stats') | length }} 
    or expected_stat_count != {{ var('pokemon_stats') | length }}
