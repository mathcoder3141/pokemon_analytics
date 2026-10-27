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

Architecture

PokéAPI
   |
   v
Python ingestion
   |
   v
DuckDB — incoming data
   |
   v
dbt staging models
   |
   v
dbt intermediate models
   |
   v
dbt marts

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

## Planned Technology Stack

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
* `dim_type`
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
