import boto3
import json
import logging
import random
import re
import string
from botocore.exceptions import ClientError
from os import environ
from backend_handler import response

logger = logging.getLogger()
logger.setLevel(logging.INFO)

USER_POOL_ID = environ["USER_POOL_ID"]

def validate_password(password):
    has_upper = bool(re.search(r'[A-Z]', password))
    has_lower = bool(re.search(r'[a-z]', password))
    has_digit = bool(re.search(r'[0-9]', password))
    has_special = bool(re.search(r'[$*.{}()"!@#%&,><:;|_~+=]', password))
    valid = has_upper and has_lower and has_digit and has_special

    return valid 

def generate_password():
    
    characters = string.ascii_lowercase + string.ascii_uppercase + string.digits + '$*.{}()?-"!@#%&,><:;|_~+='

    while True:
        password = ''.join(random.choice(characters) for _ in range(12))
    
        if validate_password(password):
            return password

def lambda_handler(event, context):

    request_body = json.loads(event['body'])
    if 'username' not in request_body:
        body = json.dumps({'message': f'Invalid request. No username provided'})
        return response(event, 400, body)
    
    username = request_body['username']
    password = generate_password()

    client = boto3.client('cognito-idp')
    
    try:
        client.admin_create_user(
            UserPoolId = USER_POOL_ID,
            Username = username
        )
        client.admin_set_user_password(
            UserPoolId = USER_POOL_ID,
            Username = username,
            Password = password,
            Permanent = True
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'UsernameExistsException':
            body = json.dumps({'message': f'Invalid request. Username already exists'})
            return response(event, 400, body)
        else:
            raise
        
    body = json.dumps({
        'password': password,
        'message': f'{username} added to users'
    })
    return response(event, 200, body)