import json
import logging 

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps(f'[{ASG_NAME},{HOSTED_ZONE_ID},{LAMBDA_ASSUME_ROLE_ARN}]')
    }