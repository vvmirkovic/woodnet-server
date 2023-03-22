import json
import logging 
import botocore
import boto3
import time
from os import environ

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ASG_NAME = environ["ASG_NAME"]
HOSTED_ZONE_ID = environ["HOSTED_ZONE_ID"]
HOSTED_ZONE_NAME = environ["HOSTED_ZONE_NAME"]
LAMBDA_ASSUME_ROLE_ARN = environ["LAMBDA_ASSUME_ROLE_ARN"]

def set_record():
    
    sts_connection = boto3.client('sts')
    acct_b = sts_connection.assume_role(
        RoleArn=LAMBDA_ASSUME_ROLE_ARN,
        RoleSessionName="start_ark_server_lambda"
    )
    
    ACCESS_KEY = acct_b['Credentials']['AccessKeyId']
    SECRET_KEY = acct_b['Credentials']['SecretAccessKey']
    SESSION_TOKEN = acct_b['Credentials']['SessionToken']

    client_asg = boto3.client("autoscaling", region_name="us-east-1")
    client_ec2 = boto3.client("ec2", region_name="us-east-1")
    client_route53 = boto3.client(
        'route53',
        aws_access_key_id=ACCESS_KEY,
        aws_secret_access_key=SECRET_KEY,
        aws_session_token=SESSION_TOKEN,
        region_name="us-east-1"
    )

    # Wait for instance to be created
    instance_found = False
    count = 0
    wait_time = 10
    while not instance_found:
        count += 1
        try:
            response = client_asg.describe_auto_scaling_groups(
                AutoScalingGroupNames=[
                    ASG_NAME,
                ]
            )
            instances = current_desired_capacity = response['AutoScalingGroups'][0]['Instances']
        except IndexError as e:
            logger.error(f'Autoscaling group does not exist. Error: {e}')
            raise e
        except KeyError as e:
            logger.error(f'Unexpected Response. Error: {e}')
            raise e 
        
        num_instance = len(instances)
        if num_instance == 0:
            total_wait_time = count * wait_time
            logger.info(f'Waiting for instance to be created by autoscaling group. Total wait time: {total_wait_time}')
        elif num_instance > 1:
            logger
        else:
            instance_found = True
            instance_id = instances[0]['InstanceId']

        if count > 60:
            total_wait_time = count * wait_time
            logger.error('Instance not created after {total_wait_time} seconds.')
            raise Exception('ASG instance not found after setting desire count to 1')

        time.sleep(wait_time)
    
    # Wait for instance public IP to be available
    ip_found = False
    count = 0
    wait_time = 5
    while not ip_found:
        count += 1
        # See if the instance info can be found. Should succeed since it was found earlier
        try:
            response = client_ec2.describe_instances(
                InstanceIds = [instance_id]
            )
            instance = response['Reservations'][0]['Instances'][0]
        except IndexError as e:
            logger.error(f'Instance not found. Error: {e}')
            raise e
        except KeyError as e:
            logger.error(f'Unexpected Response. Error: {e}')
            raise e 
        
        # Try getting IP address from instance info
        try:
            total_wait_time = count * wait_time
            public_ip = instance['PublicIpAddress']
        except KeyError:
            logger.info(f'Instance does not have an IP address after {total_wait_time}')
        else:
            ip_found = True

        if count > 60:
            total_wait_time = count * wait_time
            logger.error('Instance public IP not available after {total_wait_time} seconds after it was created.')
            raise Exception('No ASG instance public IP')

    client_route53.change_resource_record_sets(
        HostedZoneId = HOSTED_ZONE_ID,
        ChangeBatch={
            'Changes': [
                {
                    'Action': 'UPSERT',
                    'ResourceRecordSet': {
                        'Name': f'ark.{HOSTED_ZONE_NAME}',
                        'Type': 'A',
                        'ResourceRecords': [
                            {
                                'Value': public_ip
                            }
                        ],
                        'TTL': 300
                    }
                }
            ]
        }
    )

def start_ark():
    client_asg = boto3.client("autoscaling", region_name="us-east-1")

    # set new desired capacity
    try:
        client_asg.set_desired_capacity(
            AutoScalingGroupName = ASG_NAME,
            DesiredCapacity = 1
        )
    except botocore.exceptions.ClientError as e:
        logger.error(f'Client error. Error: {e}')
        raise e

def lambda_handler(event, context):
    start_ark()
    set_record()
        
    return {
        'statusCode': 200,
        'body': json.dumps(f'Server started and record has been configured with new IP')
    }