import json
import logging 

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ASG_NAME = "${asg_name}"
HOSTED_ZONE_ID = "${hosted_zone_id}"
LAMBDA_ASSUME_ROLE_ARN = "${lambda_assume_role_arn}"

def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps(f'[{ASG_NAME},{HOSTED_ZONE_ID},{LAMBDA_ASSUME_ROLE_ARN}]')
    }