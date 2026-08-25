FROM apache/airflow:3.3.1

RUN pip install --no-cache-dir \
    dbt-core==1.12.0 \
    dbt-databricks==1.12.4 \
    dbt-spark==1.10.3