import os

from airflow.sdk import dag
from datetime import datetime, timedelta
from airflow.providers.http.sensors.http import HttpSensor
from airflow.providers.standard.operators.bash import BashOperator

PROJECT_DIR = os.environ.get("POKEMON_PROJECT_DIR", "/opt/airflow/pokemon_analytics")
DBT_PROJECT_DIR = os.environ.get("DBT_PROJECT_DIR", f"{PROJECT_DIR}/pokemon_analytics")
DBT_BIN = os.environ.get("DBT_BIN", "/opt/airflow/dbt_venv/bin/dbt")

# dbt runs from its own project directory and reads profiles.yml from there.
DBT_ENV = {"DBT_PROFILES_DIR": DBT_PROJECT_DIR}

default_args = {
    "owner" : "Randall Hall",
    "retries" : 2,
    "retry_delay" : timedelta(minutes=1)
}

@dag(
    dag_id = "pokemon_etl",
    description = "ETL work flow demonstrating fluency with Airflow.",
    schedule = "@weekly",
    start_date = datetime(2026, 11, 18),
    max_active_runs = 1, # Set because of DuckDB's file lock.
    catchup = False,
    default_args = default_args,
    tags=["airflow3", "pokemon", "etl"]
)

def pokemon_pipeline_v1():
    """
    This performs multiple steps at one.

    First it:
        1a) Checks the API first.
        1) Get's all of the Pokemon from the PokeAPI's Pokemon endpoint 
        2) Gets all of the pokemon types from the PokeAPI's Types endpoint
        3) Gets all of the Pokemon's moves from the PokeAPI's Moves endpoint
        4) Creates the raw tables for the Pokemon, their types, and their moves
        5) Loads the raw data into their respective tables
    """

    check_api = HttpSensor(
        task_id="check_api",
        http_conn_id="pokeapi",           # defined via AIRFLOW_CONN_POKEAPI, see notes below
        endpoint="api/v2/pokemon?limit=1",
        poke_interval=60,
        timeout=60 * 10,
        mode="reschedule",                # frees the worker slot between checks
        retries=2,
        retry_delay=timedelta(minutes=5),
    )

    ingest = BashOperator(
        task_id = "ingest",
        bash_command = f"cd {PROJECT_DIR} && python3 src/ingest_pokemon.py",
        retries = 2,
        retry_delay = timedelta(minutes = 5),
        execution_timeout = timedelta(hours = 1)
    )

    dbt_clean = BashOperator(
        task_id = "dbt_clean",
        bash_command = f"cd {DBT_PROJECT_DIR} && {DBT_BIN} clean",
        env = DBT_ENV,
        append_env = True,
        retries = 0
    )

    dbt_deps = BashOperator(
        task_id = "dbt_deps",
        bash_command = f"cd {DBT_PROJECT_DIR} && {DBT_BIN} deps",
        env = DBT_ENV,
        append_env = True,
        retries = 0
    )

    dbt_build = BashOperator(
        task_id = "dbt_build",
        bash_command = f"cd {DBT_PROJECT_DIR} && {DBT_BIN} build",
        env = DBT_ENV,
        append_env = True,
        retries = 0
    )

    dbt_docs = BashOperator(
        task_id = "dbt_docs",
        bash_command = f"cd {DBT_PROJECT_DIR} && {DBT_BIN} docs generate",
        env = DBT_ENV,
        append_env = True,
        retries = 0
    )

    check_api >> ingest >> dbt_clean >> dbt_deps >> dbt_build >> dbt_docs

pokemon_pipeline_v1()