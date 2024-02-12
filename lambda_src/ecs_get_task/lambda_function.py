#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

import boto3
import os
import json
import time
import logging
import requests
import base64
import re

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info(os.environ['AWS_LAMBDA_LOG_GROUP_NAME'])
    logger.info(os.environ['AWS_LAMBDA_LOG_STREAM_NAME'])
    log_group_name = os.environ['AWS_LAMBDA_LOG_GROUP_NAME']

    # Extract headers from API Gateway event
    plan_url = event.get('PlanUrl')
    project_id = event.get('ProjectId')
    hub_name = event.get('HubName')
    plan_id = event.get('PlanId')
    job_id = event.get('JobId')
    task_instance_id = event.get('TaskInstanceId')
    auth_token = event.get('AuthToken')
    task_arn = event.get('TaskArn')
    adoOrg = os.environ['ADO_ORG']

    # ECS parameters - replace with your actual values
    cluster = os.environ['ECS_CLUSTER']

    # Create an ECS client
    ecs_client = boto3.client('ecs')

    # Run the ECS task
    # get status of running task
    response = ecs_client.describe_tasks(
        cluster=cluster,
        tasks=[task_arn]
    )
    
    # Check if task was successfully started
    task_arn = response['tasks'][0]['taskArn'] if response.get('tasks', []) else None
    result = 'failed' if task_arn is None else None


    # Wait until task is running or stopped
    while result is None:
        response = ecs_client.describe_tasks(
            cluster=cluster,
            tasks=[task_arn]
        )

        logger.info('response from ECS for describe task:')
        logger.info(response)

        status = response['tasks'][0]['lastStatus'] if response.get('tasks', []) else None

        if status == 'RUNNING':
            result = "succeeded"
            ado_events_url = f"https://dev.azure.com/{adoOrg}/{project_id}/_apis/distributedtask/hubs/{hub_name}/plans/{plan_id}/events?api-version=7.1-preview.1"
        
            headers = {
            'Accept': 'application/json',
            'Authorization': 'Basic '+str((base64.b64encode(bytes('ecs-ado-callback:'+auth_token, 'ascii'))), 'ascii')
            }
            
            
            body = {"name": "TaskCompleted", "taskId": task_instance_id, "jobId": job_id, "result": result}
        
            logger.info('ado post succeeded details:')
            logger.info(ado_events_url)
            logger.info(body)

            response = requests.request("POST", ado_events_url, headers=headers, json=body)
        
            logger.info("response from ADO:")
            logger.info(response)
        
            # Return a successful response with desired body
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'name': 'TaskCompleted',
                    'taskId': task_instance_id,
                    'jobId': job_id,
                    'result': result,
                    'azureDevOpsResponse': str(response)
                })
            }
        elif status == 'STOPPED':
            result = "failed"
            ado_events_url = f"https://dev.azure.com/{adoOrg}/{project_id}/_apis/distributedtask/hubs/{hub_name}/plans/{plan_id}/events?api-version=7.1-preview.1"
        
            headers = {
            'Accept': 'application/json',
            'Authorization': 'Basic '+str((base64.b64encode(bytes('ecs-ado-callback:'+auth_token, 'ascii'))), 'ascii')
            }
            body = {"name": "TaskCompleted", "taskId": task_instance_id, "jobId": job_id, "result": result}
            logger.info('ado post failure details:')
            logger.info(ado_events_url)
            logger.info(body)
            
            response = requests.request("POST", ado_events_url, headers=headers, json=body)            

            return {
                'statusCode': 500,
                'body': json.dumps({
                    'name': 'TaskCompleted',
                    'taskId': task_instance_id,
                    'jobId': job_id,
                    'result': result,
                    'azureDevOpsResponse': str(response)
                })
            }
