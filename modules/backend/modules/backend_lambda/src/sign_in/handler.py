import boto3
import json
import logging
from botocore.exceptions import ClientError
from os import environ
from backend_handler import response

logger = logging.getLogger()
logger.setLevel(logging.INFO)

CLIENT_ID = environ["CLIENT_ID"]

def lambda_handler(event, context):

    body = json.loads(event['body'])
    if 'username' not in body or 'password' not in body:
        return response(
                event,
                400,
                json.dumps(f'Invalid request. Must provide username and password')
            )
        # {
        #     'statusCode': 400,
        #     'body': json.dumps(f'Invalid request. Must provide username and password')
        # }
    
    username = body['username']
    password = body['password']

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
            return response(
                event,
                400,
                json.dumps(f'Invalid username and password.')
            )
        # {
        #         'statusCode': 400,
        #         'headers': {
        #             "Access-Control-Allow-Headers" : "Content-Type",
        #             "Access-Control-Allow-Origin": "https://dev.woodnet.io",
        #             "Access-Control-Allow-Methods": "OPTIONS,POST"
        #         },
        #         'body': json.dumps(f'Invalid username and password.')
        #     }
        else:
            raise
    
    # if 'ChallengeName' in response_init and response_init['ChallengeName'] == 'NEW_PASSWORD_REQUIRED':
    #     return {
    #         statusCode': 301
    #     }
    
    return response(
        event,
        200,
        json.dumps({
            'message': response_init['AuthenticationResult']
        })
    )