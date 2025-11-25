# AIRFLOW
Airflow, is an open-source platform used for programmatically authoring, scheduling, and monitoring workflows

## FLOW
A task starts with `no_status` then it scheduled by a `scheduler` and then `executor` puts the task in the task queue which is picked by the `worker` to execute it.

## KEYWORDS
- DAG- Directed Acyclic Graph. Collection of Tasks and the relation.
- Task- Each work unit inside a DAG. Defines what an operator should be doing.
    - Tasks at any given time can be in one of the stage.
    - Stages- [no_status, queued, running, skipped, success]
- Operator- Task is an implementation of an operator
- Sensor- Type of operator which waits for something to occur.
- Dependencies
- catchup- True(default)- Makes dag run for all past dates since start date
- backfill- To run for select previous dates 
    - syntax- `airflow dags backfill -s {start_date} -e {end_date} {dag_id}`


## OPERATORS
```python
PythonOperator(
    task_id = 'unique_task_id',
    python_callable = greet_me,
    op_kwargs = {'name': 'Shasank', 'age': 20} #assuming the functions takes an input of name and age   
) 
```

## SENSORS
Since Sensors are primarily idle, Sensors have two different modes of running so you can be a bit more efficient about using them:
- poke (default): The Sensor takes up a worker slot for its entire runtime
- reschedule: The Sensor takes up a worker slot only when it is checking, and sleeps for a set duration between checks

## XCOMM
Recommended size of XComm is 48KB. It usually depends on the underlying database used. Ex- PostgreSQL: 1GB MySQL: 64KB <br>
```python
# A task returning a dictionary
@task(do_xcom_push=True, multiple_outputs=True)
def push_multiple(**context):
    return {"key1": "value1", "key2": "value2"}


@task
def xcom_pull_with_multiple_outputs(**context):
    # Pulling a specific key from the multiple outputs
    key1 = context["ti"].xcom_pull(task_ids="push_multiple", key="key1")
    key2 = context["ti"].xcom_pull(task_ids="push_multiple", key="key2")

    # Pulling entire xcom data from push_multiple task
    data = context["ti"].xcom_pull(task_ids="push_multiple", key="return_value")
```
[XComm example dag](sample_dags/xcomm_example.py)


## CONNECTION
To connect to different services, add connection from the connection tab.


## TASK PARALLELIZATION
    start_task >> [parallel_task1, parallel_task2, parallel_task3] >> end_task


## CROSS DAG DEPENDENCIES
`ExternalTaskSensor` and `TriggerDagRunOperator` can be used to establish dependencies across different DAGs.


## TASK GROUP
```python
@task_group(group_id='dependent_tasks')
    def run_dependent_tasks():
        @task(task_id='first_task')
        def first_task():
            print('First task')

        @task(task_id='second_task')
        def second_task():
            print('Second task')

        first_task() >> second_task()

run_dependent_tasks()
```

## HOOK
Hooks are interfaces to services external to the Airflow Cluster. While Operators provide a way to create tasks that may or may not communicate with some external service.

### ⚖️ EXECUTION_DELTA VS EXECUTION_DATE_FN
|`execution_delta`                                        |`execution_date_fn`                                  |
|---------------------------------------------------------|-----------------------------------------------------|
|Subtracts from the **current DAG run’s execution\_date** |Full control — you return **any datetime** manually  |

The key difference:
-   ✅ execution_delta=timedelta(days=1) → simpler for fixed offsets
-   ✅ execution_date_fn=lambda dt: dt.replace(hour=0) → more flexible (e.g., align to start of day, week)
<br>You cannot use both — only one of execution_delta or execution_date_fn is allowed.


https://chatgpt.com/share/684d888f-3ef4-800d-88a9-8f77b862f793

## EXECUTORS
1. SequentialExecutor(default)- Runs tasks one at a time, sequentially, in the scheduler process.
2. LocalExecutor- Runs tasks in parallel processes on the same machine as the scheduler.
3. CeleryExecutor- Distributes tasks across multiple workers using a Celery backend (requires a message broker like RabbitMQ or Redis).
4. KubernetesExecutor- Runs each task in a separate Kubernetes pod, offering resource isolation and flexibility.
5. Hybrid & Other Executors- Hybrid Executors: As of Airflow 2.10+, you can configure multiple executors in the same environment

Sequential Executor is the reason why simply setting parallel tasks won't work.

## TRIGGER RULES
Trigger rules available in Airflow:
- all_success (default): Task runs only when all upstream tasks have succeeded.
- all_failed: Task runs only when all upstream tasks have failed or are in an upstream_failed state.
- all_done: Task runs once all upstream tasks are finished, regardless of success or failure.
- all_skipped: Runs only if all upstream tasks have been skipped.
- one_failed: Runs if at least one upstream task has failed.
- one_success: Runs if at least one upstream task has succeeded.
- one_done: Runs if at least one upstream task has either succeeded or failed.
- none_failed: Runs only if no upstream task has failed (i.e., all succeeded or were skipped).
- none_failed_min_one_success: Runs only if no upstream tasks failed and at least one succeeded.
- none_skipped: Runs only if no upstream task was skipped.
- always: Runs regardless of any upstream task states.

## SLA(SERVICE LEVEL AGREEMENT) & TIMEOUTS
### SLA
To enable SLA, in `airflow.cfg` set `check_slas = True`<br>
SLAs only apply to scheduled DAG runs, not manually triggered runs. <br>
**SLA timing**: The SLA is measured from the DAG run start time, not from when the individual task starts(which is not the case with timeouts).<br>
**SLA vs. Timeouts**: SLAs are for monitoring and reporting when a task exceeds its expected completion time. They do not automatically terminate a running task. If you want to enforce a maximum runtime and potentially cancel a task, use the execution_timeout parameter instead.

### TIMEOUTS
| Parameter         | Scope           | Applies To                      | Purpose                                      |
| ----------------- | --------------- | ------------------------------- | -------------------------------------------- |
| execution_timeout | Individual Task | All operators & sensors         | Limits max runtime of a single task instance |
| dagrun_timeout    | Entire DAG      | DAG level                       | Limits total runtime of entire DAG run       |
| timeout           | Sensor Task     | Only sensors in reschedule mode | Limits max time for sensor to succeed        |

## QnA
1. How to schedule dags to only run on business days? What if it should only be run on 12 business days?
    >If you need to skip official holidays as well as weekends, cron expressions alone aren’t enough. In this case, you can use a custom Timetable (from Airflow 2.2+). This allows for sophisticated scheduling, such as programmatically skipping certain dates based on a holiday calendar.

2.  DAG didn't get imported, how to check?
    >Check for syntactical errors - `python /opt/airflow/dags/reddit_dag.py`<br>
    Check for import errors - `airflow dags list-import-errors`

3.  DAG added but not showing.
    >`airflow dags reserialize`

4. Pain points if Airflow didn't exist.
    - Managing all the pipelines under one roof
    - Handle retries 
    - Write operators by ourselves
    - No single source of truth for pipeline status
    - No visual representation of task relationships
    - Changing the schedule would be a new task
    - Centralized monitoring and alerting
    - Complex dependency management
    - Historical execution tracking

5. How to identify long running jobs in Airflow? 
    >SLA- Service Level Agreement- {"sla": timedelta(hours=2)} We can set max time it may take. Tasks over their SLA are not cancelled, though - they are allowed to run to completion. If you want to cancel a task after a certain runtime is reached, you want Timeouts instead.
