with raw_types as (

    select
        id as attacking_type_id,
        raw_json
    from {{ ref('incoming_types') }}

),

relations as (

    select
        attacking_type_id,
        'double' as relation,
        2.0::double as multiplier,
        raw_json['damage_relations']['double_damage_to'] as relation_list
    from raw_types

    union all

    select
        attacking_type_id,
        'half' as relation,
        0.5::double as multiplier,
        raw_json['damage_relations']['half_damage_to'] as relation_list
    from raw_types

    union all

    select
        attacking_type_id,
        'none' as relation,
        0.0::double as multiplier,
        raw_json['damage_relations']['no_damage_to'] as relation_list
    from raw_types
),

penultimate as (

    select
        attacking_type_id,
        relation,
        multiplier,
        json_extract_string(
            je.value,
            '$.name'
        ) as defending_type_name
    from relations,
        unnest(json_transform(relation_list, '["JSON"]')) as je(value)

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key([
            'attacking_type_id',
            'defending_type_name'
            ])
        }} as pk_damage_relations,
        attacking_type_id,
        relation,
        multiplier,
        defending_type_name
    from penultimate
)

select * from final
