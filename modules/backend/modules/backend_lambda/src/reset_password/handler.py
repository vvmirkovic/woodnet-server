import boto3
import json
import logging
from botocore.exceptions import ClientError
from backend_handler import response

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):

    request_body = json.loads(event['body'])
    if 'previous_password' not in request_body and 'new_password' not in request_body:
        body = json.dumps({'message': f'Invalid request. Must provide previous_password and password'})
        return response(event, 400, body)
    
    previous_password = request_body['previous_password']
    new_password = request_body['new_password']

    client = boto3.client('cognito-idp')
    
    try:
        client.change_password(
            PreviousPassword=previous_password,
            ProposedPassword=new_password,
            AccessToken=event['headers']['accesstoken']
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'NotAuthorizedException':
            body = json.dumps(f'User unauthorized to reset password.')
            return response(event, 400, body)
        elif e.response['Error']['Code'] == 'InvalidPasswordException':
            body = json.dumps(f'Invalid previous password provided.')
            return response(event, 400, body)
        else:
            raise

        
    return response(event, 200, json.dumps("Password reset successfully."))