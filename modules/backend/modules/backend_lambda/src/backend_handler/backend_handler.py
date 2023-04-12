import json

def success(event, message):
    headers = {}

    if event['httpMethod'] in ['OPTIONS', 'POST', 'PUT']:
        headers = headers | {
            "Access-Control-Allow-Headers" : "Content-Type",
            "Access-Control-Allow-Origin": "${frontend_domain}",
            "Access-Control-Allow-Methods": event['httpMethod']
        }

    return {
        'statusCode': 200,
        'headers': headers,
        'body': json.dumps({
            'message': message
        })
    }