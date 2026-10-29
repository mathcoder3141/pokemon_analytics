with expected_combinations as (

    select
        attacking.type_id as attacking_type_id,
        defending.type_id as defending_type_id
    from {{ ref('stg_types') }} as attacking
    cross join {{ ref('stg_types') }} as defending

),

actual_combinations as (

    select
        attacking_type_id,
        defending_type_id
    from {{ ref('dim_type_effectiveness') }}

),

missing_combinations as (

    select
        expected.attacking_type_id,
        expected.defending_type_id,
        'missing' as failure_reason
    from expected_combinations as expected
    left join actual_combinations as actual
        on expected.attacking_type_id = actual.attacking_type_id
        and expected.defending_type_id = actual.defending_type_id
    where actual.attacking_type_id is null

),

unexpected_combinations as (

    select
        actual.attacking_type_id,
        actual.defending_type_id,
        'unexpected' as failure_reason
    from actual_combinations as actual
    left join expected_combinations as expected
        on actual.attacking_type_id = expected.attacking_type_id
        and actual.defending_type_id = expected.defending_type_id
    where expected.attacking_type_id is null

)

select * from missing_combinations
union all
select * from unexpected_combinations
