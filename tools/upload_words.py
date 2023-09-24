import json
import csv
import boto3


def main():
    # for profile in boto3.session.Session().available_profiles:
    #     print(profile)
    # mfa_token = input("Enter the MFA code: ")

    # sts_client = boto3.client('sts')
    # iam_client = boto3.client('iam')

    # username = sts_client.get_caller_identity()['Arn'].split('/')[-1]
    
    # mfa_token = input(f"Enter MFA code for {username}: ")

    # mfa_serial = iam_client.list_mfa_devices(UserName=username)['MFADevices'][0]['SerialNumber']
    
    # mfa_creds = sts_client.get_session_token(
    #     DurationSeconds=900,
    #     SerialNumber=mfa_serial,
    #     TokenCode=mfa_token
    # )

    # session = boto3.session.Session(
    #     profile_name='dynamodbdev',
    #     aws_access_key_id=mfa_creds['Credentials']['AccessKeyId'],
    #     aws_secret_access_key=mfa_creds['Credentials']['SecretAccessKey'],
    #     aws_session_token=mfa_creds['Credentials']['SessionToken']
    # )
    # iam_client = session.client('iam')

    # role_creds = iam_client.assume_role(
    # )
    # session = boto3.session.Session(
    #     profile_name='dynamodbdev',
    #     aws_access_key_id=mfa_creds['Credentials']['AccessKeyId'],
    #     aws_secret_access_key=mfa_creds['Credentials']['SecretAccessKey'],
    #     aws_session_token=mfa_creds['Credentials']['SessionToken']
    # )
    # client = session.client('dynamodb')

    session = boto3.session.Session(
        profile_name='dynamodbdev'
    )
    client = session.client('dynamodb')
    with open('src/words.csv', 'r', encoding="utf8") as f:
        reader = csv.reader(f, delimiter=',')

        for i, row in enumerate(reader):

            print(f"Adding row\n{i} {row}\n")

            client.put_item(
                TableName="flashcards",
                Item={
                    "id": {
                        "N": str(i)
                    },
                    "croatian": {
                        "S": row[0]
                    },
                    "english": {
                        "S": row[1]
                    }
                }
            )

if __name__ == '__main__':
    main()
