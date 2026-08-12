with

src as (

    select
        pokemon_id,
        species_id,
        species_json
    from {{ ref('incoming_pokemon_species') }}

),

pokemon_species as (

    select
        pokemon_id,
        species_id,
        
        cast(species_json.base_happiness as integer) as base_happiness,
        cast(species_json.capture_rate as integer) as capture_rate,

        json_extract_string(
            species_json,
            '$.growth_rate.name'
        ) as growth_rate_name,

        json_extract_string(
            species_json,
            '$.habitat.name'
        ) as habitat_name,

        json_extract_string(
            species_json,
            '$.generation.name'
        ) as generation_name,

        cast(species_json.has_gender_differences as boolean) as has_gender_differences,
        cast(species_json.hatch_counter as integer) as hatch_counter,
        cast(species_json.is_baby as boolean) as is_baby,
        cast(species_json.is_mythical as boolean) as is_mythical,
        cast(species_json.is_legendary as boolean) as is_legendary,
        cast(species_json.name as varchar) as species_name
    from src
)

select * from pokemon_species
