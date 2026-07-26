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

## ⏳ Phase 3 – Store Raw Data in DuckDB

Objectives:

* Create a local DuckDB database
* Create raw ingestion tables
* Store each Pokémon's complete JSON response
* Preserve the original API response for downstream transformations

---

## ⏳ Phase 4 – Build dbt Models

Create staging models that normalize the raw JSON into analytical tables.

Potential models include:

* `stg_pokemon`
* `stg_types`
* `stg_abilities`
* `stg_moves`
* `stg_stats`

---

## ⏳ Phase 5 – Analytics Models

Build dimensional models including:

* `dim_pokemon`
* `dim_type`
* `fact_pokemon_stats`
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
