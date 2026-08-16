with pokemon_moves as (

    select
        move_id,
        move_name,
        move_url
    from {{ ref('int_pokemon_moves') }}
    group by 1, 2, 3

)

select * from pokemon_moves
