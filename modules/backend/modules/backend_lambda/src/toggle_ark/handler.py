import json
import logging 
from os import environ

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps(f'[{environ["ASG_NAME"]},{environ["HOSTED_ZONE_ID"]},{environ["LAMBDA_ASSUME_ROLE_ARN"]}]')
    }