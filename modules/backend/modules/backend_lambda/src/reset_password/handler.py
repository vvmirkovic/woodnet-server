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

def lambda_handler(event, context):

    body = json.loads(event['body'])
    if 'previous_password' not in body and 'password' not in body:
        return {
            'statusCode': 400,
            'body': json.dumps(f'Invalid request. Must provide previous_password and password')
        }
    
    previous_password = body['previous_password']
    password = body['password']

    client = boto3.client('cognito-idp')
    
    try:
        client.change_password(
            PreviousPassword=previous_password,
            ProposedPassword=password,
            AccessToken=event['headers']['accesstoken']
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
        'body': json.dumps("Password reset successfully.")
    }