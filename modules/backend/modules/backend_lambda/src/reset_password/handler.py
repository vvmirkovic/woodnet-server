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
            ClientId=self.client_id, 
            AuthFlow='USER_PASSWORD_AUTH',
            AuthParameters={
                'USERNAME': username, 
                'PASSWORD': password
            }
        )
        print(response_init['AuthenticationResult'])
    except ClientError as e:
        if e.response['Error']['Code'] == 'UsernameExistsException':
            return {
                'statusCode': 400,
                'body': json.dumps(f'Invalid request. Username already exists')
            }
    except KeyError:
        return {
            'statusCode': 400,
            'body': json.dumps(f'Password authentication failed. Further Challenges required.')
        }
        
    return {
        'statusCode': 200,
        'body': json.dumps({
            'password': temp_password,
            'message': f'{username} added to users'
        })
    }