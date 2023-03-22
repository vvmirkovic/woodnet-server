import json
import logging 
import botocore
import boto3
from os import environ

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ASG_NAME = environ["ASG_NAME"]

def stop_ark():
    client_asg = boto3.client("autoscaling", region_name="us-east-1")

    # set new desired capacity
    try:
        client_asg.set_desired_capacity(
            AutoScalingGroupName = ASG_NAME,
            DesiredCapacity = 0
        )
    except botocore.exceptions.ClientError as e:
        logger.error(f'Client error. Error: {e}')
        raise e

def lambda_handler(event, context):
    stop_ark()
        
    return {
        'statusCode': 200,
        'body': json.dumps(f'Server started and record has been updated with IP')
    }