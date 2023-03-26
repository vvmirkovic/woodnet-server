import boto3
import json
import logging
import random
import re
import string
from botocore.exceptions import ClientError
from os import environ

logger = logging.getLogger()
logger.setLevel(logging.INFO)

USER_POOL_ID = environ["USER_POOL_ID"]

def lambda_handler(event, context):

    if 'password' not in event:
        return {
            'statusCode': 400,
            'body': json.dumps(f'Invalid request. Must provide username and password')
        }
    
    password = event['password']

    client = boto3.client('cognito-idp')
    
    try:
        response = client.change_password(
            PreviousPassword='string',
            ProposedPassword='string',
            AccessToken='string'
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'NotAuthorizedException':
            return {
                'statusCode': 400,
                'body': json.dumps(f'Invalid username and password.')
            }
        else:
            raise

        
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': response_init['AuthenticationResult']
        })
    }