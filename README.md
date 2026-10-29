# Pokémon Analytics Pipeline

## Overview

This project is an end-to-end Analytics Engineering portfolio project built around the public PokeAPI. The goal is to gain hands-on experience with modern data engineering and analytics engineering tools by building a production-inspired data pipeline from scratch.

Rather than simply consuming an API, this project will demonstrate how data is ingested, stored, transformed, tested, orchestrated, and ultimately exposed for analytics.

## Goals

* Learn API ingestion using Python
* Store raw API responses in a local analytical database
* Build data models using dbt
* Orchestrate the pipeline with Apache Airflow
* Create analytics-ready tables and dashboards
* Practice software engineering best practices through incremental development

## Architecture

PokéAPI

&darr;

Python ingestion

&darr;

DuckDB — incoming data

&darr;

dbt staging models

&darr;

dbt intermediate models

&darr;

dbt marts

## Getting Started

### Prerequisites

* Python 3.9
* Git
* Optional: the [DuckDB CLI](https://duckdb.org/docs/installation/) for exploring the database

### Setup

```bash
git clone https://github.com/mathcoder3141/pokemon_analytics.git
cd pokemon_analytics

python -m venv .venv
source .venv/bin/activate

pip install -r requirements.txt
```

dbt connects to a local DuckDB file, `pokemon.duckdb`, in the project root. Make sure your
dbt profile (`profiles.yml`) points its `path` at that file.

### Run the workflow

Until the Airflow DAG is built (Phase 6), the pipeline runs as three manual steps:

```bash
# 1. Ingest: retrieve the Pokémon index and details from PokeAPI and load the raw payloads into DuckDB
python3 src/ingest_pokemon.py

# 2. Transform: build the staging, intermediate and marts models and run the data tests
cd pokemon_analytics
dbt build

# 3. Explore: query the marts
duckdb pokemon.duckdb
```

`dbt build` runs each model followed by its tests, in dependency order. To run only the
transformations or only the tests, use `dbt run` or `dbt test`.

Each layer lands in its own DuckDB schema:

| Layer          | Schema              |
|----------------|---------------------|
| 1_incoming     | `incoming`     |
| 2_staging      | `staging`      |
| 3_intermediate | `intermediate` |
| 4_marts        | `marts`        |

The queries in [Example Analyses](#example-analyses) run against `marts`.

### Troubleshooting

**`Could not set lock on file ... pokemon.duckdb`**: DuckDB allows only one process to hold
the database file at a time. Close any open DuckDB CLI session, notebook or SQL client before
running ingestion or dbt, and the reverse.

## Data Model

Models are organized into four layers:

| Layer                 | Purpose                                                 | Examples
|-----------------------|---------------------------------------------------------|-----------------------------------------------------------
| 1_incoming     | Retain ingested API data and source payloads                   | incoming_pokemon, incoming_moves, incoming_types
| 2_staging      | Standardize source data into relational models                 | stg_pokemon, stg_pokemon_moves, stg_pokemon_species
| 3_intermediate | Apply reusable transformations and unpack nested relationships | int_pokemon_moves, int_type_damage_relations
| 4_marts        | Expose analytical dimensions and relationship models           | dim_pokemon, dim_moves, dim_pokemon_stats, dim_type_effectiveness, bridge_pokemon_moves

The marts distinguish entities from relationships. For example, `dim_moves` describes moves, while `bridge_pokemon_moves` represents the moves a Pokémon can learn.

`dim_type_effectiveness` describes the type matchup multiplier between an attacking move type and a defending Pokémon type. It represents type effectiveness, not the complete damage calculation for an individual move.

## Data Quality and Documentation

The dbt project uses model and column descriptions alongside data tests to document and validate its data contracts.

Testing includes:

- Unique and non-null checks for key columns
- Composite uniqueness checks for relationship tables
- Relationship checks between related models
- Accepted-value checks for categorical attributes

The intended grain of each model determines which uniqueness tests are appropriate. For example, a Pokémon-to-move relationship has a different grain and purpose from the move dimension.

## Example Analyses

The marts can answer questions like these directly. All queries below count each
species once, using its base form (the lowest `pokemon_id`), because `dim_pokemon` also
contains alternate forms such as Mega evolutions and cosmetic variants.

### 1. Which Pokémon type has the highest average base stats?

```sql
with base_forms as (
    select species_id, min(pokemon_id) as pokemon_id
    from marts.dim_pokemon
    group by species_id
),
pokemon_by_type as (
    select pokemon_id, primary_type_name as type_name
    from marts.dim_pokemon_types
    union all
    select pokemon_id, secondary_type_name
    from marts.dim_pokemon_types
    where secondary_type_name is not null
)
select
    t.type_name,
    count(*) as species_count,
    round(avg(s.base_stat_total), 1) as avg_base_stat_total
from base_forms as b
inner join pokemon_by_type as t
    on b.pokemon_id = t.pokemon_id
inner join marts.dim_pokemon_stats
    on b.pokemon_id = s.pokemon_id
group by t.type_name
order by avg_base_stat_total desc
limit 5;
```

| type_name | species_count | avg_base_stat_total |
|-----------|--------------:|--------------------:|
| dragon    | 70            | 504.8               |
| steel     | 65            | 479.7               |
| fighting  | 73            | 467.1               |
| dark      | 69            | 459.6               |
| psychic   | 102           | 457.5               |

Dual-type species count toward both of their types.

### 2. How have Pokémon changed across generations?

```sql
with base_forms as (
    select species_id, min(pokemon_id) as pokemon_id
    from marts.dim_pokemon
    group by species_id
)
select
    sp.generation_name,
    count(*) as species_count,
    round(avg(s.base_stat_total), 1) as avg_base_stat_total,
    round(avg(s.attack), 1) as avg_attack,
    round(avg(s.speed), 1) as avg_speed
from base_forms as b
inner join marts.dim_pokemon_species as sp using (species_id)
    on b.species_id = sp.species_id
inner join marts.dim_pokemon_stats s using (pokemon_id)
    on b.pokemon_id = s.pokemon_id
group by sp.generation_name
order by min(b.species_id);
```

| generation_name | species_count | avg_base_stat_total | avg_attack | avg_speed |
|-----------------|--------------:|--------------------:|-----------:|----------:|
| generation-i    | 151           | 407.6               | 72.9       | 69.1      |
| generation-ii   | 100           | 407.2               | 68.3       | 61.4      |
| generation-iii  | 135           | 403.7               | 73.1       | 61.6      |
| generation-iv   | 107           | 445.6               | 80.2       | 69.5      |
| generation-v    | 156           | 425.8               | 81.0       | 66.6      |
| generation-vi   | 72            | 429.3               | 72.5       | 65.7      |
| generation-vii  | 88            | 449.4               | 84.8       | 65.4      |
| generation-viii | 96            | 439.2               | 82.9       | 68.9      |
| generation-ix   | 120           | 457.4               | 82.4       | 75.5      |

Average base stats were flat through the first three generations and have trended
upward since, with Generation IX highest at 457.4.

### 3. Which type combinations are the rarest?

```sql
with base_forms as (
    select species_id, min(pokemon_id) as pokemon_id
    from marts.dim_pokemon
    group by species_id
),
all_combos as (
    select a.type_name || '/' || b.type_name as combo
    from (select distinct primary_type_name as type_name from marts.dim_pokemon_types) as a
    inner join (select distinct primary_type_name as type_name from marts.dim_pokemon_types) as b
      on a.type_name < b.type_name
),
observed as (
    select
        least(primary_type_name, secondary_type_name) || '/' ||
        greatest(primary_type_name, secondary_type_name) as combo,
        count(*) as species_count
    from base_forms
    inner join marts.dim_pokemon_types using (pokemon_id)
    where secondary_type_name is not null
    group by 1
)
select c.combo, coalesce(o.species_count, 0) as species_count
from all_combos as c
left join observed as o
    on c.combo = o.combo
order by species_count, c.combo
limit 5;
```

| combo          | species_count |
|----------------|--------------:|
| bug/dragon     | 0             |
| bug/normal     | 0             |
| dragon/fairy   | 0             |
| electric/fire  | 0             |
| electric/grass | 0             |

Of the 153 possible dual-type combinations, 17 have no species at all. Combinations are
treated as unordered, so Fire/Flying and Flying/Fire are the same.

## Technology Stack

| Component            | Technology                        |
| -------------------- | --------------------------------- |
| Programming Language | Python                            |
| API                  | PokeAPI                           |
| Data Warehouse       | DuckDB                            |
| Transformation       | dbt Core                          |
| Orchestration        | Apache Airflow                    |
| Version Control      | Git & GitHub                      |
| Dashboarding         | TBD (Metabase or Apache Superset) |

---

# Development Progress

## ✅ Phase 1 – Retrieve Pokémon Index

### Objective

Retrieve every available Pokémon from the PokeAPI, regardless of how many pages of results exist.

### What was implemented

* Connected to the PokeAPI using the `requests` library.
* Implemented pagination using the API's `next` field.
* Collected every Pokémon into a single Python list.
* Extracted each Pokémon's:

  * Name
  * Detail endpoint URL

The result of this phase is a complete Pokémon index that can be used to retrieve detailed information for each Pokémon.

### Current Flow

```
PokeAPI
    ↓
Retrieve paginated Pokémon index
    ↓
Python List
[
    {
        "name": "...",
        "url": "..."
    }
]
```

---

# Upcoming Milestones

## ✅ Phase 2 – Retrieve Pokémon Details

For each Pokémon returned by the index:

* Request the detailed Pokémon endpoint
* Retrieve the complete JSON payload
* Validate successful responses

Expected output:

```
Pokemon Index
        ↓
For each Pokémon
        ↓
GET detail endpoint
        ↓
Complete Pokémon JSON
```

---

## ✅ Phase 3 – Store Raw Data in DuckDB

Objectives:

* Create a local DuckDB database
* Create raw ingestion tables
* Store each Pokémon's complete JSON response
* Preserve the original API response for downstream transformations

---

## ✅ Phase 4 – Build dbt Models

Create staging models that normalize the raw JSON into analytical tables.

Potential models include:

* `stg_pokemon`
* `stg_pokemon_types`
* `stg_pokemon_abilities`
* `stg_pokemon_moves`
* `stg_pokemon_stats`
* `stg_pokemon_species`

---

## ✅ Phase 5 – Analytics Models

Build dimensional models including:

* `dim_pokemon`
* `dim_pokemon_types`
* `dim_type_effectiveness`
* Bridge tables for many-to-many relationships

---

## ⏳ Phase 6 – Airflow Orchestration

Create an Airflow DAG to automate:

1. Retrieve Pokémon index
2. Retrieve Pokémon details
3. Load raw data
4. Execute dbt models
5. Run data quality tests
6. Refresh analytics outputs

---

## ⏳ Phase 7 – Dashboards

Develop dashboards to answer questions such as:

* Which Pokémon type has the highest average stats?
* How have Pokémon changed across generations?
* Which type combinations are the rarest?
* What abilities appear most frequently?
* Distribution of Pokémon by generation and type

---

# Long-Term Vision

The objective is to simulate a production Analytics Engineering workflow using a publicly available dataset.

By the end of the project, the pipeline should demonstrate:

* REST API ingestion
* Data warehouse design
* Raw data preservation
* Data transformation with dbt
* Workflow orchestration with Airflow
* Data quality testing
* Analytical modeling
* Dashboard creation

This project is intended to mirror the architecture and practices commonly used by modern Analytics Engineering teams while providing a fun and engaging dataset to explore.
