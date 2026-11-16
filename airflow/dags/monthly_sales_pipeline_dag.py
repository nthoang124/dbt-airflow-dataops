from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'data_engineering',
    'depends_on_past': False,
    'start_date': datetime(2026, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=2),
    'env': {
        'DOCKER_API_VERSION': '1.44'   # <-- Injects API 1.44 into all bash tasks
    }
}

with DAG(
    dag_id='monthly_sales_performance_pipeline',
    default_args=default_args,
    description='Automated pipeline for Monthly Sales Performance and Cohort Analysis',
    schedule_interval='@monthly',
    catchup=False,
    tags=['sales', 'dbt', 'sqlserver'],
) as dag:
    # 1. Staging Layer
    run_staging = BashOperator(
        task_id='dbt_run_staging',
        bash_command='docker exec dbt_airflow_project-dbt-1 dbt run --select staging',
    )
    test_staging = BashOperator(
        task_id='dbt_test_staging',
        bash_command='docker exec dbt_airflow_project-dbt-1 dbt test --select staging',
    )
    # 2. Intermediate Layer
    run_intermediate = BashOperator(
        task_id='dbt_run_intermediate',
        bash_command='docker exec dbt_airflow_project-dbt-1 dbt run --select intermediate',
    )
    # 3. Marts Layer
    run_marts = BashOperator(
        task_id='dbt_run_marts',
        bash_command='docker exec dbt_airflow_project-dbt-1 dbt run --select marts',
    )
    test_marts = BashOperator(
        task_id='dbt_test_marts',
        bash_command='docker exec dbt_airflow_project-dbt-1 dbt test --select marts',
    )
    # 4. Pipeline Lineage Execution Flow
    run_staging >> test_staging >> run_intermediate >> run_marts >> test_marts
