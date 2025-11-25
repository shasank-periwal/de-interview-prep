from airflow import DAG 
from airflow.operators.dummy import DummyOperator 
from airflow.operators.python import PythonOperator, ShortCircuitOperator, BranchPythonOperator
from airflow.providers.cncf.kubernetes.operators.kubernetes_pod import KubernetesPodOperator
from datetime import datetime, timedelta
from airflow.models import Variable, TaskInstance
import pytz
from google.cloud import bigquery,storage
from pendulum import duration
import yaml
import os
import ast
import json 
import logging as logs
from airflow.utils.state import State


bucket_name =  'BUCKET_NAME'
manifest_name = 'dbt_config/ontology_manifest.json'

project_id = 'PROJECT_ID'
source_dataset = 'SOURCE_DATASET'
target_dataset = 'TARGET_DATASET'
target_location = 'TARGET_LOCATION'
no_of_threads = NO_OF_THREADS
image_path = 'DOCKER_IMG'
table_types = 'TABLE_TYPES'
ontology_dag_state_table_fqn = 'ONTOLOGY_DAG_STATE_FQN'
state_table_fqn = 'PROJECT_ID'+'.'+'STATE_TABLE_FQN'
retries = RETRIES
retry_delay = RETRY_DELAY
concurrency = CONCURRENCY
first_cob_date = 'FIRST_COB_DATE'
f_batch_table_fqn ='PROJECT_ID'+'.'+ 'F_BATCH_TABLE_FQN'


if isinstance(table_types, str) and table_types.startswith("[") and table_types.endswith("]"):
    table_types = ast.literal_eval(table_types)

def remove_prefix_from_satellite(satellite):
    prefixes = ["raw_", "v_stg_"]
    for prefix in prefixes:
        if satellite.startswith(prefix):
            return satellite[len(prefix):]
    return satellite    
 
def state_exists_in_table(satellite, state_table_fqn=state_table_fqn, **kwargs):
    
    satellite = remove_prefix_from_satellite(satellite)
    client = bigquery.Client(location="asia-southeast1")
    
    try:
        # Query to check if the table has records for the satellite
        check_state_exist_query = f"""
            SELECT MAX(systm_dt) AS systm_dt
            FROM `{state_table_fqn}`
            WHERE table_name = '{satellite}'
        """
        logs.info("check_state_exist_query:::: %s", check_state_exist_query)

        check_state_exist_query_results = client.query(check_state_exist_query).result()
        check_state_exist_query_df = check_state_exist_query_results.to_dataframe()
        check_state_exist_query_system_dt = (check_state_exist_query_df.iloc[0]["systm_dt"] if not check_state_exist_query_df.empty else None )

        logs.info("check_state_exist_query_system_dt:::: %s", check_state_exist_query_system_dt)

        if check_state_exist_query_system_dt is None:
            is_full_refresh = True
            is_full_refresh_var = '--full-refresh'
        else:
            is_full_refresh = False
            is_full_refresh_var = ''

        kwargs['ti'].xcom_push(key=f'state_exists_in_table', value=is_full_refresh_var)
        return is_full_refresh

    except Exception as e:
        # If an error occurs (e.g., table doesn't exist or query failure), return full refresh
        logs.error(f"Error while executing query: {str(e)}")
        
   
def dbt_satellite_run(satellite,**kwargs):

    systm_frm_op_dt = "{{dag_run.conf['systm_frm_op_dt']}}"
    systm_to_op_dt = "{{dag_run.conf['systm_to_op_dt']}}"
    systm_dt = "{{dag_run.conf['systm_dt']}}"

    task_id = f'{satellite}'

    is_full_refresh = "{{ti.xcom_pull(task_ids='state_exists_in_table_task_"+ remove_prefix_from_satellite(satellite) +"',key='state_exists_in_table') }}"

    logs.info(f"is_full_refresh variable is :{is_full_refresh}")

    dbt_run_command = f"dbt --debug run -m {satellite} {is_full_refresh} --vars '{{\"from_dts\":\"{systm_frm_op_dt}\",\"to_dts\":\"{systm_to_op_dt}\",\"systm_dt\":\"{systm_dt}\",\"project_id\":\"{project_id}\",\"source_dataset\":\"{source_dataset}\",\"target_dataset\":\"{target_dataset}\",\"target_location\":\"{target_location}\",\"no_of_threads\":{no_of_threads}}}'"  


    execute_command_task = KubernetesPodOperator(
        name=task_id,
        dag=dag,
        namespace="dbt",
        image=image_path,
        service_account_name='dbt-sa',
        image_pull_policy='Always',
        cmds=[
            "bash", "-cx", 
            dbt_run_command
            ],
        arguments=["echo", "10"],
        labels={"NCB": "ontology"},
        get_logs = True,
        task_id=task_id,
        trigger_rule='all_success',
        retries = retries,
        retry_delay = duration(seconds=retry_delay),
    )
    return execute_command_task

def get_successful_upstream_task_ids(**kwargs):
    ti = kwargs['ti']
    upstream_task_ids = ti.task.upstream_task_ids
    successful_task_ids = []
    
    for upstream_task_id in upstream_task_ids:
        upstream_ti = TaskInstance(task=ti.task.dag.get_task(upstream_task_id), execution_date=ti.execution_date)
        upstream_ti.refresh_from_db()
        if upstream_ti.state == State.SUCCESS:
            successful_task_ids.append(upstream_task_id)
    
    kwargs['ti'].xcom_push(key=f'get_successful_upstream_task_ids', value=successful_task_ids)
    return successful_task_ids

def write_ontology_dag_state(ontology_dag_state_table_fqn,domain = table_types,**context):
    client = bigquery.Client(location="asia-southeast1")
    ontology_dag_table_id = ontology_dag_state_table_fqn 

    # Create or update the table schema
    create_table_query = f"""
    CREATE TABLE IF NOT EXISTS `{ontology_dag_table_id}` (
        domain STRING,
        systm_dt STRING,
        ld_dt_tm TIMESTAMP DEFAULT CURRENT_TIMESTAMP() 
    );
    """
    client.query(create_table_query).result()

    rows_to_insert = []
    
    systm_dt = context['dag_run'].conf['systm_dt']
    rows_to_insert.append({u"systm_dt": systm_dt, "domain": domain})
    logs.info(f"Ontology Dag state inserted for :{domain}")
    print(f":::: {rows_to_insert}:::")
    
    # Insert all the rows into BigQuery
    client = bigquery.Client()

    errors = client.insert_rows_json(ontology_dag_table_id, rows_to_insert)
    
    if errors:
        raise Exception(f"Encountered errors while inserting rows: {errors}")
    else:
        print(f"Successfully pushed start times for tables.")


def insert_to_bigquery(state_table_fqn, successful_tasks, **context):
    table_names = raw_vault_tables
    rows_to_insert = []
    
    if not successful_tasks:
        logs.info("No rows present in successful_tasks.")
        return 
    
    systm_frm_op_dt = context['dag_run'].conf.get('systm_frm_op_dt')
    systm_to_op_dt = context['dag_run'].conf.get('systm_to_op_dt')
    systm_dt = context['dag_run'].conf.get('systm_dt')
    
    logs.info(f"systm_frm_op_dt: {systm_frm_op_dt}, systm_to_op_dt: {systm_to_op_dt}, systm_dt: {systm_dt}")
    
    for table_name in table_names:
        if table_name in successful_tasks:
            logs.info(f"Successful table: {table_name}")
            if systm_frm_op_dt and systm_to_op_dt:
                rows_to_insert.append({
                    "table_name": table_name,
                    "systm_frm_op_dt": systm_frm_op_dt,
                    "systm_to_op_dt": systm_to_op_dt,
                    "systm_dt": systm_dt,
                })
                logs.info(f"Inserted data for table: {table_name}")
    
    logs.info(f"Rows to insert: {rows_to_insert}")
    
    if not rows_to_insert:
        logs.warning("No rows to insert into BigQuery. Skipping insertion.")
        return
    
    client = bigquery.Client()
    table_id = state_table_fqn
    
    create_table_query = f"""
    CREATE TABLE IF NOT EXISTS `{table_id}` (
        table_name STRING,
        systm_frm_op_dt STRING,
        systm_to_op_dt STRING,
        systm_dt STRING,
        ld_dt_tm TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
    );
    """
    client.query(create_table_query).result()
    logs.info(f"Ensured table exists: {table_id}")
    
    errors = client.insert_rows_json(table_id, rows_to_insert)
    if errors:
        raise Exception(f"Encountered errors while inserting rows: {errors}")
    else:
        logs.info(f"Successfully pushed start times for tables.")


def get_tables_to_run_incrementally(**context):
    tables_to_run_incrementally = context["dag_run"].conf.get("tables_to_run_incrementally", [])
    
    if not isinstance(tables_to_run_incrementally, list):
        raise ValueError("tables_to_run_incrementally must be a list.")

    logs.info(f"Following tables to be run incrementally: {tables_to_run_incrementally}")

    Variable.set("tables_to_run_incrementally", json.dumps(tables_to_run_incrementally))


def check_tables_to_run_incrementally_list(table_name, **kwargs):
    try:
        tables_to_run_incrementally = json.loads(
            Variable.get("tables_to_run_incrementally", default_var="[]")
        )
    except Exception as e:
        raise ValueError(f"Error retrieving tables_to_run_incrementally: {str(e)}")
    
    if not tables_to_run_incrementally:
        return True
    
    if remove_prefix_from_satellite(table_name) in tables_to_run_incrementally:
        return True
    else:
        return False


def check_to_write_dag_state(**kwargs):
    try:
        tables_to_run_incrementally = json.loads(
            Variable.get("tables_to_run_incrementally", default_var="[]")
        )
    except Exception as e:
        raise ValueError(f"Error retrieving tables_to_run_incrementally: {str(e)}")
    
    if not tables_to_run_incrementally:
        return "write_ontology_dag_state_task"
    else:
        return "end_table_wise_ontology_run_task"
 
if isinstance(table_types, list):  
    dag_id = "ONTOLOGY_PIPELINE"  
else: 
    dag_id = f"ONTOLOGY_PIPELINE_{table_types.upper()}"


with DAG(
        dag_id=dag_id,
        default_args={
            'owner': 'airflow',
            'retries': retries,
            'retry_delay': timedelta(minutes=1),
        },
        catchup=False,
        concurrency=concurrency,
        schedule= None,
        start_date=datetime(2024, 12, 24),
        max_active_runs=1,
        tags=["ncb", "Ontology"],
) as dag:
    
    start_ontology = DummyOperator(
        task_id='start_ontology'
    )

    def load_manifest(bucket_name, manifest_name):
        # Initialize a GCS client
        client = storage.Client()
        # Get the bucket and manifest
        bucket = client.bucket(bucket_name)
        manifest = bucket.blob(manifest_name)
        # Download the manifest as a string
        json_string = manifest.download_as_text()
        # Parse the JSON string into a Python dictionary
        data = json.loads(json_string)
        return data   

    
    end_ontology = DummyOperator(
        trigger_rule = 'none_failed', # to run regardless of skips
        task_id='end_ontology'
    )

    end_table_wise_ontology_run_task = DummyOperator(
        trigger_rule = 'all_done', # to run regardless of skips
        task_id='end_table_wise_ontology_run_task'
    )

    get_successful_upstream_task_ids_task = PythonOperator(
        trigger_rule = 'all_done',
        task_id='get_successful_upstream_task_ids_task',
        python_callable=get_successful_upstream_task_ids,
        provide_context=True,
        retries = retries,
        retry_delay = duration(seconds=retry_delay),
    )

    write_state_task = PythonOperator(
        trigger_rule = 'all_done',
        task_id='write_state_task',
        python_callable=insert_to_bigquery,
        op_kwargs={"state_table_fqn": state_table_fqn,
                   "successful_tasks" : "{{ ti.xcom_pull(task_ids='get_successful_upstream_task_ids_task',key='get_successful_upstream_task_ids') }}"},
        provide_context=True,
        retries = retries,
        retry_delay = duration(seconds=retry_delay),
    )

    branch_check_to_write_dag_state_task = BranchPythonOperator(
        task_id='check_to_write_dag_state',
        python_callable=check_to_write_dag_state,
        trigger_rule="all_success",
        dag=dag)
    
    write_ontology_dag_state_task = PythonOperator(
        trigger_rule = 'all_success',
        task_id='write_ontology_dag_state_task',
        python_callable=write_ontology_dag_state,
        op_kwargs={"ontology_dag_state_table_fqn": ontology_dag_state_table_fqn},
        provide_context=True,
        retries = retries,
        retry_delay = duration(seconds=retry_delay),
    )

    get_tables_to_run_incrementally_task = PythonOperator(
        trigger_rule = 'all_success',
        task_id='get_tables_to_run_incrementally',
        python_callable=get_tables_to_run_incrementally,
        provide_context=True,
        retries = retries,
        retry_delay = duration(seconds=retry_delay),
    )
    

    branch_check_to_write_dag_state_task.set_downstream(write_ontology_dag_state_task)
    branch_check_to_write_dag_state_task.set_downstream(end_table_wise_ontology_run_task)

    dbt_manifest_manifest = load_manifest(bucket_name, manifest_name)

    if not table_types:
        ontology_tables = [
        str(node).split(".")[2]
        for node in dbt_manifest_manifest["nodes"].keys()
        if node.split(".")[0] == "model"
        ]   
    elif isinstance(table_types, list):
        ontology_tables = [
            str(node).split(".")[2]
            for node in dbt_manifest_manifest["nodes"].keys()
            if node.split(".")[0] == "model" and any(sat in node.split(".")[2] for sat in table_types)
        ]  
    else:
        if table_types == 'lnk':
            table_types = ['l_']

        elif table_types == 'rfrnc':
            table_types = ['r_']

        else:
            table_types = [f"h_{table_types}", f"s_{table_types}"]

        ontology_tables = [
                str(node).split(".")[2]
                for node in dbt_manifest_manifest["nodes"].keys()
                if node.split(".")[0] == "model" 
                and any(node.split(".")[2].startswith(sat) or 
                        node.split(".")[2].startswith(f"raw_{sat}") or 
                        node.split(".")[2].startswith(f"v_stg_{sat}") for sat in table_types)
        ]

dbt_tasks = {}
view_models = []

for node in dbt_manifest_manifest["nodes"].keys():
    if node.split(".")[0] == "model":
        if str(node).split(".")[2] in ontology_tables:
            if str(node).split(".")[2].startswith('raw_'):
                print("node:",node)

                short_circuit_task = ShortCircuitOperator(
                    task_id=f'check_if_model_should_run_{remove_prefix_from_satellite(str(node).split(".")[2])}',
                    python_callable=check_tables_to_run_incrementally_list,
                    op_kwargs={"table_name": str(node).split(".")[2]},
                    ignore_downstream_trigger_rules=False,
                    provide_context=True,
                )

                state_exists_in_table_task = PythonOperator(
                    trigger_rule = 'all_done',
                    task_id=f'state_exists_in_table_task_{remove_prefix_from_satellite(str(node).split(".")[2])}',
                    python_callable=state_exists_in_table,
                    op_kwargs={"satellite": str(node).split(".")[2]},
                    provide_context=True,
                    retries = retries,
                    retry_delay = duration(seconds=retry_delay),
                )

                dbt_task = dbt_satellite_run(str(node).split(".")[2])
                dbt_tasks[node] = dbt_task
                start_ontology >> get_tables_to_run_incrementally_task >> short_circuit_task >> state_exists_in_table_task >> dbt_task
            else:
                dbt_tasks[node] = dbt_satellite_run(str(node).split(".")[2])
        

# Set model dependencies
for node in dbt_manifest_manifest["nodes"].keys():
    if node.split(".")[0] == "model":
        if str(node).split(".")[2] in ontology_tables:
            for upstream_node in dbt_manifest_manifest["nodes"][node]["depends_on"]["nodes"]:
                upstream_node_type = upstream_node.split(".")[0]
                if upstream_node_type == "model":
                    dbt_tasks[upstream_node] >> dbt_tasks[node]
        else:
            continue

raw_vault_tables = [i for i in ontology_tables if i.startswith(('h_','l_','s_','r_'))]
for satellite in raw_vault_tables:
    dag.get_task(f'{satellite}') >> end_ontology >> write_ontology_dag_state_task
    dag.get_task(f'{satellite}') >> get_successful_upstream_task_ids_task >> write_state_task >> branch_check_to_write_dag_state_task
