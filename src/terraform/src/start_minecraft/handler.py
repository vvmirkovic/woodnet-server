import json
import boto3
import logging

from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_password():
    secret_name = "MinecraftPassword"
    region_name = "us-east-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    s = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = s.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        logger.info(str(e))
    else:
        secret = json.loads(get_secret_value_response['SecretString'])
    
    try:
        logger.info(f'secret: {type(secret)}')
        password = secret['password']
    except KeyError:
        logger.error('Invalid secret')
    
    return password 

def authenticate(request_password):
    password = get_password()
    try:
        if request_password != password:
            return {
                'statusCode': 401,
                'body': json.dumps('Invalid password')
            }
    except KeyError:
        return {
                'statusCode': 400,
                'body': json.dumps('Invalid request data')
            }

    return True

def find_server(client):
    Filters=[
        {
            'Name': 'tag:Name',
            'Values': [
                'Minecraft Server',
            ]
        },
        {
            'Name': 'tag:Creator',
            'Values': [
                'API triggered',
            ]
        }
    ]

    instances = []
    response = client.describe_instances(Filters=Filters)

    instances_full_details = response['Reservations']
    for instance_detail in instances_full_details:
        logger.info(str(instance_detail))
        instances += [x['InstanceId'] for x in instance_detail['Instances'] if x['State']['Name'] != 'terminated']

    return instances


def lambda_handler(event, context):
    auth_result = authenticate(event['password'])
    if isinstance(type(auth_result), dict):
        return auth_result

    c = boto3.client("ec2")
    r = boto3.resource("ec2")

    servers = find_server(c)
    if servers:
        return {
            'statusCode': 200,
            'body': json.dumps('Minecraft Server is already running')
        }

    response = r.create_instances(
        LaunchTemplate = {"LaunchTemplateName":"minecraft"},
        MinCount = 1,
        MaxCount = 1
    )
    
    logger.info(response)
    
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda poop!')
    }