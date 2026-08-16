with pokemon_species as (

    select * from {{ ref('stg_pokemon_species') }}

),

unique_pokemon as (

    select
        species_id,
        base_happiness,
        capture_rate,
        growth_rate_name,
        habitat_name,
        generation_name,
        has_gender_differences,
        hatch_counter,
        is_baby,
        is_mythical,
        is_legendary,
        species_name
    from pokemon_species
    {{ dbt_utils.group_by(n=12) }}
),

pokemon_forms as (

    select
        species_id,
        count(pokemon_id) as num_forms
    from pokemon_species
    group by 1
)

select
    unique_pokemon.species_id,
    unique_pokemon.species_name,
    unique_pokemon.base_happiness,
    unique_pokemon.capture_rate,
    unique_pokemon.growth_rate_name,
    unique_pokemon.habitat_name,
    unique_pokemon.generation_name,
    unique_pokemon.has_gender_differences,
    unique_pokemon.hatch_counter,
    unique_pokemon.is_baby,
    unique_pokemon.is_mythical,
    unique_pokemon.is_legendary,
    pokemon_forms.num_forms
from unique_pokemon
inner join pokemon_forms
    on unique_pokemon.species_id = pokemon_forms.species_id