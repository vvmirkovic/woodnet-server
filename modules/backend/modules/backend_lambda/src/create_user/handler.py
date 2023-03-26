import logging 
import boto3
import re
import string
from os import environ

logger = logging.getLogger()
logger.setLevel(logging.INFO)

USER_POOL_ID = environ["USER_POOL_ID"]

def validate_password(password):
    has_upper = bool(re.search(r'[A-Z]', name))
    has_lower = bool(re.search(r'[a-z]', name))
    has_digit = bool(re.search(r'[0-9]', name))
    has_special = bool(re.search(r'[$*.{}()?-"!@#%&,><:;|_~+=]', name))
    valid = has_upper and has_lower and has_digit and has_special

    return valid 

def generate_password():
    letters = string.ascii_uppercase + string.digits 
    special_characters = '$*.{}()?-"!@#%&,><:;|_~+='
    characters = letters + special_characters

    while True:
        password = ''.join(random.choice(characters) for _ in range(12))
    
        if validate(password):
            return password



def lambda_handler(event, context):
    CognitoIdentityProvider.Client.admin_create_user

    if 'username' not in event:
        return {
            'statusCode': 400,
            'body': json.dumps(f'Invalid reuest. No username provided')
        }
    
    username = event['username']
    temp_password = generate_password()

    client = boto3.client('cognito')
    client.admin_create_user(
        UserPoolId = USER_POOL_ID
        Username = username
        TemporaryPassword = temp_password
    )
        
    return {
        'statusCode': 200,
        'body': json.dumps({
            'password': password
            'message': f'{username} added to users')
    }