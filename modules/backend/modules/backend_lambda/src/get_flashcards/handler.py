import boto3
import json
import logging
import datetime
import random
from backend_handler import response

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_week():
    current_date = datetime.date.today()

    week_number = current_date.isocalendar()[1]

    return week_number

def get_day_of_week():
    current_date = datetime.date.today()

    day_of_week = current_date.weekday()

    return day_of_week

def get_words(database_name, day_of_week, week, number_of_words):
    client = boto3.client('dynamodb')

    seed_value = week * 7 + day_of_week
    random.seed(seed_value)

    n = client.describe_table(TableName=database_name)['Table']['ItemCount']

    selected_words = []

    for _ in range(number_of_words):
        random_word_id = random.randint(0, n)

        item = client.get_item(
            TableName=database_name,
            Key={
                'id': {
                    'N': str(random_word_id)}
            }
        )

        selected_words.append((
            item['Item']['croatian'],
            item['Item']['english']
        ))

    return selected_words
        

def lambda_handler(event, context):
    parameters = event['pathParameters']
    try:
        # Determine day of week
        if parameters["day_of_week"] == -1:
            day_of_week = get_day_of_week()
        else:
            day_of_week = parameters["day_of_week"]

        try:
            assert day_of_week >= 0
            assert day_of_week <= 6
        except AssertionError:
            body = json.dumps({'message': f'Specify value 0 and 6 to specify a day of the week.'})
            return response(event, 400, body)    
            
        # Determine week
        if parameters["week"] == -1:
            week = get_day_of_week()
        else:
            week = parameters["week"]

        try:
            assert week >= 0
            assert week <= 53
        except AssertionError:
            body = json.dumps({'message': f'Specify an integer between 0 and 53.'})
            return response(event, 400, body)
            
        database_name = parameters["flashcard_set"]
        number_of_words = parameters["number_of_words"]

    except KeyError:
        body = json.dumps({'message': f'Missing argument(s).'})
        return response(event, 400, body)
    
    selected_words = get_words(database_name, day_of_week, week, number_of_words)

    body = json.dumps({
        'cards': selected_words
    })

    return response(event, 200, body)