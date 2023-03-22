import json
import logging 
import botocore
import boto3
from os import environ

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ASG_NAME = environ["ASG_NAME"]
HOSTED_ZONE_ID = environ["HOSTED_ZONE_ID"]
LAMBDA_ASSUME_ROLE_ARN = environ["LAMBDA_ASSUME_ROLE_ARN"]

def set_record():
    pass

def start_ark():
    client = boto3.client("autoscaling", region_name="us-east-1")

    # determine current desired capacity and new desired capacity 
    # try:
    #     response = client.describe_auto_scaling_groups(
    #         AutoScalingGroupNames=[
    #             ASG_NAME,
    #         ]
    #     )
    #     current_desired_capacity = response['AutoScalingGroups'][0]['DesiredCapacity']
    #     new_capacity = (current_desired_capacity + 1) % 2
    # except botocore.exceptions.ClientError as e:
    #     logger.error(f'Client error. Error: {e}')
    #     raise e
    # except IndexError as e:
    #     logger.error(f'Autoscaling group does not exist. Error: {e}')
    #     raise e
    # except KeyError:
    #     logger.error(f'Unexpected Response. Error: {e}')
    #     raise e

    # set new desired capacity
    try:
        response = client.set_desired_capacity(
            AutoScalingGroupName = ASG_NAME,
            DesiredCapacity = new_capacity
        )
    except botocore.exceptions.ClientError as e:
        logger.error(f'Client error. Error: {e}')
        raise e

def lambda_handler(event, context):
    start_ark()
    set_record()
        
    return {
        'statusCode': 200,
        'body': json.dumps(f'[{environ["ASG_NAME"]},{environ["HOSTED_ZONE_ID"]},{environ["LAMBDA_ASSUME_ROLE_ARN"]}]')
    }