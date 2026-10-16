select
    id as type_id,
    name as type_name,
    source_url as type_url
from {{ ref('incoming_types') }}
    /*
    Functionally, the following types don't do anything so omitting for downstream:
        * shadow
        * unknown
        * stellar
    */
    where name not in ('shadow', 'unknown', 'stellar')