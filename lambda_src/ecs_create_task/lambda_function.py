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

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info(os.environ['AWS_LAMBDA_LOG_GROUP_NAME'])
    logger.info(os.environ['AWS_LAMBDA_LOG_STREAM_NAME'])
    
    # Extract headers from API Gateway event
    plan_url = event['headers'].get('PlanUrl')
    project_id = event['headers'].get('ProjectId')
    hub_name = event['headers'].get('HubName')
    plan_id = event['headers'].get('PlanId')
    job_id = event['headers'].get('JobId')
    task_instance_id = event['headers'].get('TaskInstanceId')
    auth_token = event['headers'].get('AuthToken')
        
    # ECS parameters - replace with your actual values
    cluster = os.environ['ECS_CLUSTER']
    task_definition = os.environ['ECS_TASK_DEFINITION']
    # Create an ECS client
    ecs_client = boto3.client('ecs')

    # Run the ECS task
    response = ecs_client.run_task(
        cluster=cluster,
        taskDefinition=task_definition,
        count=1,
        launchType='FARGATE',
        networkConfiguration={
            'awsvpcConfiguration': {
                'subnets': [os.environ['SUBNET_IDs']],
                'securityGroups': [os.environ['SECURITY_GROUP_IDs']],
                'assignPublicIp': 'ENABLED'
            }
        }
    )
    
    lambda_client = boto3.client('lambda')
    lambda_client.invoke(

        FunctionName=os.environ['CALLBACK_FUNCTION_NAME'],
        InvocationType='Event',

        Payload=json.dumps({
                'PlanUrl': plan_url,
                'ProjectId': project_id,
                'HubName': hub_name,
                'PlanId': plan_id,
                'JobId': job_id,
                'TaskInstanceId': task_instance_id,
                'AuthToken': auth_token,
                'TaskArn': response['tasks'][0]['taskArn']
        })
    )

    # Return a successful response with desired body
    return {
        'statusCode': 200
    }