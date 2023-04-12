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

    request_body = json.loads(event['body'])
    if 'username' not in request_body or 'password' not in request_body:
        body = json.dumps({'message': f'Invalid request. Must provide username and password'})
        return response(event, 400, body)
    
    username = request_body['username']
    password = request_body['password']

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
            body = json.dumps({'message': f'Invalid username and password.'})
            return response(event, 400, body)
        else:
            raise
    
    # if 'ChallengeName' in response_init and response_init['ChallengeName'] == 'NEW_PASSWORD_REQUIRED':
    #     return {
    #         statusCode': 301
    #     }
    
    body = json.dumps(response_init['AuthenticationResult'])
    return response(event, 200, body)