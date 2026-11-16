from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'dbt_transform',
    default_args=default_args,
    description='Run dbt models',
    schedule_interval=timedelta(minutes=5),
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['dbt', 'sqlserver'],
)

# Define tasks using BashOperator to execute dbt commands in the dbt container
dbt_run = BashOperator(
    task_id='dbt_run',
    bash_command='docker exec dbt_airflow_project-dbt-1 dbt run',
    dag=dag,
)

dbt_test = BashOperator(
    task_id='dbt_test',
    bash_command='docker exec dbt_airflow_project-dbt-1 dbt test',
    dag=dag,
)
dbt_docs = BashOperator(
    task_id='dbt_docs_generate',
    bash_command='cd /opt/airflow/dbt && dbt docs generate',
    dag=dag
)

dbt_freshness = BashOperator(
    task_id='dbt_source_freshness',
    bash_command='cd /opt/airflow/dbt && dbt source freshness',
    dag=dag
)
# Set task dependencies
dbt_freshness >> dbt_run >> dbt_test >> dbt_docs 