FROM apache/airflow:3.0.0
COPY airflow-requirements.txt /airflow-requirements.txt
RUN pip install --no-cache-dir "apache-airflow==${AIRFLOW_VERSION}" -r /airflow-requirements.txt
COPY dbt-requirements.txt /dbt-requirements.txt /
RUN python -m venv /opt/airflow/dbt_venv && \
    /opt/airflow/dbt_venv/bin/pip install --no-cache-dir -r /dbt-requirements.txt