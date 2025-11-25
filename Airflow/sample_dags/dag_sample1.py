from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.providers.amazon.aws.operators.emr import EmrAddStepsOperator,EmrCreateJobFlowOperator,EmrModifyClusterOperator,EmrTerminateJobFlowOperator
from airflow.providers.amazon.aws.sensors.emr import EmrStepSensor,EmrJobFlowSensor
from airflow.operators.dagrun_operator import TriggerDagRunOperator
from airflow.utils.task_group import TaskGroup
from airflow.models import Variable 
from datetime import timedelta
from airflow.utils.dates import days_ago
from utils.utils import sender_email_function, get_credentials
from datetime import datetime
import json


emr_cluster_name = Variable.get('emr_cluster_name')
step_concurrency = 4
number_of_cores = 1
number_of_tasks = 1
dagid = 'dim_product_version_file_dump'
instancetype = 'm6g.4xlarge'
ecr_image_no = Variable.get('ecr_image_no')

job_flow_overrides = {
        "Name": f"{emr_cluster_name}",
        "ReleaseLabel": "emr-6.10.0",
        "Applications": [{"Name": "Hadoop"}, {"Name": "Hive"}, {"Name": "Spark"}],
        "LogUri": "s3://bharti-axa-uat-edl-consumption/EMR-logs/",
        "VisibleToAllUsers":True,
        "StepConcurrencyLevel":step_concurrency,
        "SecurityConfiguration":"bhartiaxa-emr-airflow-sg",
        "EbsRootVolumeSize":50,
        "Configurations": [
                {
                    "Classification": "spark-hive-site",
                    "Properties": {
                        "hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory",
                        "hive.server2.authentication": "NOSASL",
                        "hive.server2.thrift.port": "10001"
                    }
                },
                {
                    "Classification": "spark-defaults",
                    "Properties": {
                        "spark.sql.parquet.datetimeRebaseModeInRead": "CORRECTED",
                        "spark.sql.parquet.datetimeRebaseModeInWrite": "CORRECTED",
                        "spark.dynamicAllocation.enabled": "true"
                    }
                },
                {
                    "Classification":"hive-site",
                    "Properties":  {
                        "hive.metastore.client.factory.class":"com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory",
                        "hive.metastore.schema.verification": "true"
                    }
                },
            ],
        "Instances": {
            "InstanceGroups": [
                {
                    "Name": "Master node",
                    "Market": "ON_DEMAND",
                    "InstanceRole": "MASTER",
                    "InstanceType": instancetype,
                    "InstanceCount": 1,
                },
                {
                    "Name": "Core node",
                    "Market": "ON_DEMAND",
                    "InstanceRole": "CORE",
                    "InstanceType": instancetype,
                    "InstanceCount": number_of_cores,
                },
                {
                    "Name": "Task node",
                    "Market": "ON_DEMAND", 
                    "InstanceRole": "TASK",
                    "InstanceType": instancetype,
                    "InstanceCount": number_of_tasks,
                }
            ],
            "Ec2SubnetId": "subnet-0f44603e61b7ac19f",
            "EmrManagedMasterSecurityGroup": "sg-04e4a5c0004a8025d",
            "EmrManagedSlaveSecurityGroup": "sg-01b8a0fef9d2ee8f6",
            "ServiceAccessSecurityGroup": "sg-0b9e3ca1bcb806c5c",
            "Ec2KeyName" : "default-uat",
            "KeepJobFlowAliveWhenNoSteps": True,
            "TerminationProtected": False,# Setting this as false will allow us to programmatically terminate the cluster
        },
        "BootstrapActions": [
                {
                    "Name": "bootstrap script",
                    "ScriptBootstrapAction": 
                    {
                        "Path": "s3://bharti-axa-uat-edl-artifacts/EMR_SCRIPTS/bootstrap.sh",
                        "Args": []
                    }
                },
            ],
        "JobFlowRole": "AmazonEMR-InstanceProfile-20240722T125448",
        "ServiceRole": "arn:aws:iam::388606509852:role/service-role/AmazonEMR-ServiceRole-20240722T125506",
        "AutoTerminationPolicy": {
            "IdleTimeout": 3600
        },
        "Tags":[
            {
                "Key": "Project",
                "Value": "BhartiLife_Data_Platform"
            },
            {
                "Key": "Environment",
                "Value": "UAT"
            },
            {
                "Key": "Managed-By",
                "Value": "TTN"
            },
            {
                "Key": "Name",
                "Value": "EMR"
            }
        ]
    }

default_args = {
    'owner': 'BAXA',
    'email_on_failure': False,
    'email_on_retry': False,
    # 'retries': 0,
    # 'retry_delay': timedelta(minutes=5),
    'on_failure_callback': sender_email_function
}

with DAG(
    dag_id= dagid,
    default_args=default_args,
    start_date=days_ago(5),
    schedule_interval= '30 6 * * *',
    catchup=False,
    max_active_runs=2
) as dag:

    start_task = DummyOperator(task_id="start_task")

    stop_task = DummyOperator(task_id="stop_task")

    create_emr_cluster = EmrCreateJobFlowOperator(
        task_id="create_cluster",
        job_flow_overrides=job_flow_overrides
    )

    is_emr_cluster_created = EmrJobFlowSensor(
        task_id="is_emr_cluster_created", 
        job_flow_id="{{ task_instance.xcom_pull(task_ids='create_cluster', key='return_value') }}",
        target_states={"WAITING"},
        timeout=3600,
        poke_interval=60,
        mode='poke'
    )
    add_step_task = EmrAddStepsOperator(
        task_id=f'add_emr_step',
        job_flow_id="{{ task_instance.xcom_pull(task_ids='create_cluster', key='return_value') }}",
        steps=[{
                "Name": "dim_product_version_file_dump",
                "ActionOnFailure": "CONTINUE",
                "HadoopJarStep": {
                    "Jar": "command-runner.jar",
                    "Args": [
                        "bash",
                        "-c",
                        "aws s3 cp s3://bharti-axa-uat-edl-artifacts/EMR_SCRIPTS/steps/steps.sh . && chmod +x steps.sh && bash steps.sh \"--jobName ProductVersionJob --JOB_NAME ProductVersionJob --src ProductVersionJob --jobType Transformation\""
                    ]
                }
            }],
        pool='mirror_pool',
        do_xcom_push=True,
        retries=5,
        retry_delay=timedelta(minutes=5),
        retry_exponential_backoff=False
    )

    is_step_executed = EmrStepSensor(
        task_id="is_step_executed", 
        job_flow_id="{{ task_instance.xcom_pull(task_ids='create_cluster', key='return_value') }}",
        step_id="{{ task_instance.xcom_pull(task_ids='add_emr_step', key='return_value')[0] }}",
        aws_conn_id='aws_default',
        retries=5,
        retry_delay=timedelta(minutes=5),
        retry_exponential_backoff=False
    )

    terminate_cluster = EmrTerminateJobFlowOperator(
        task_id="terminate_cluster",
        job_flow_id="{{ task_instance.xcom_pull(task_ids='create_cluster', key='return_value') }}",
        trigger_rule="all_success"
    )
    start_task >> create_emr_cluster >> is_emr_cluster_created >> add_step_task >> is_step_executed >> terminate_cluster >> stop_task