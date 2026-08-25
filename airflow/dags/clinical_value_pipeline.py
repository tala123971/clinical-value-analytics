from datetime import datetime
import os
import subprocess
import tempfile

import yaml
from airflow import DAG
from airflow.decorators import task
from airflow.models.connection import Connection


with DAG(
    dag_id="clinical_value_pipeline",
    start_date=datetime(2026, 8, 25),
    schedule=None,
    catchup=False,
    tags=["clinical-value", "dbt"],
) as dag:

    @task
    def run_dbt():
        connection = Connection.get_connection_from_secrets("databricks_default")
        extra = connection.extra_dejson

        profile = {
            "dbt_clinical_value": {
                "target": "dev",
                "outputs": {
                    "dev": {
                        "type": "databricks",
                        "host": connection.host,
                        "http_path": extra["http_path"],
                        "catalog": extra["catalog"],
                        "schema": connection.schema,
                        "token": connection.password,
                        "threads": 4,
                    }
                },
            }
        }

        with tempfile.TemporaryDirectory() as tmpdir:
            profiles_path = os.path.join(tmpdir, "profiles.yml")

            with open(profiles_path, "w") as f:
                yaml.safe_dump(profile, f)

            env = os.environ.copy()
            env["DBT_PROFILES_DIR"] = tmpdir

            subprocess.run(
                [
                    "dbt",
                    "run",
                    "--project-dir",
                    "/opt/airflow/dbt_clinical_value",
                ],
                env=env,
                check=True,
            )

    run_dbt()
