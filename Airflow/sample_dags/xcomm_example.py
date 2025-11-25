from airflow import DAG
from airflow.operator import PythonOperator
from datetime import datetime, timedelta

# Python functions
def print_name(age, ti): # ti- Task Instance- Since xcom can only be called by ti.
    name = ti.xcom_pull(task_ids = 'task2')
    print(f"Hello my name is: {name} and my age is: {age}")

def get_name():
    return 'Shasank'

# xcom with multiple returns required
def print_full_name(ti): # ti- Task Instance- Since xcom can only be called by ti.
    first_name = ti.xcom_pull(task_ids = 'task12', key='first_name')
    last_name = ti.xcom_pull(task_ids = 'task12', key='last_name')
    age = ti.xcom_pull(task_ids = 'task13', key='age')
    print(f"Hello my name is: {first_name} {last_name} and my age is: {age}")

def get_age(ti):
    ti.xcom_push(key='age', value = 20)

def get_full_name(ti):
    ti.xcom_push(key='first_name', value = 'Shasank')
    ti.xcom_push(key='last_name', value = 'Periwal')

default_args = {
    'owner' : 'Shasank',
    'retries' : 5,
    'retry_delay' : timedelta(minutes = 5)
}

with DAG (
    dag_id = 'unique_id',
    default_args = default_args,
    description = 'First Dag',
    start_date = datetime(2020, 1, 27),
    schedule_interval = '@daily'
) as dag:
    task1 = PythonOperator(
        task_id = 'task1',
        python_callable = print_name,
        op_kwargs = {'age' : 20} 
    )
    
    task2 = PythonOperator(
        task_id = 'task2',
        python_callable = get_name
    )
    
    task11 = PythonOperator(
        task_id = 'task11',
        python_callable = print_full_name,
        op_kwargs = {'age' : 20} 
    )
    
    task12 = PythonOperator(
        task_id = 'task12',
        python_callable = get_full_name
    )

    task13 = PythonOperator(
        task_id = 'task13',
        python_callable = get_age
    )

    task2 >> task1
    
    [task12, task13] >> task11
