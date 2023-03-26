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

CLIENT_ID = environ["CLIENT_ID"]

def lambda_handler(event, context):

    if 'username' not in event or 'password' not in event:
        return {
            'statusCode': 400,
            'body': json.dumps(f'Invalid request. Must provide username and password')
        }
    
    username = event['username']
    password = event['password']

    client = boto3.client('cognito-idp')
    
    try:
        response_init = client.initiate_auth(
            AuthFlow='USER_PASSWORD_AUTH',
            AuthParameters={
                'USERNAME': username, 
                'PASSWORD': password
            },
            ClientId=CLIENT_ID
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'NotAuthorizedException':
            return {
                'statusCode': 400,
                'body': json.dumps(f'Invalid username and password.')
            }
    except KeyError:
        return {
            'statusCode': 400,
            'body': json.dumps(f'Password authentication failed. Further Challenges required: {response_init['ChallengeName']}')
        }
        
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': response_init['AuthenticationResult']
        })
    }