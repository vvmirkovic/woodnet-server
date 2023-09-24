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

    n = client.describe_table(TableName='string')['Table']['ItemCount']

    selected_words = []

    for _ in range(number_of_words):
        random_word_id = random.randint(0, n)

        item = client.get_item(
            TableName=database_name,
            Key={
                'id': {
                    'N': random_word_id}
            }
        )

        selected_words.append((
            item['Item']['croatian'],
            item['Item']['english']
        ))

    return selected_words
        

def lambda_handler(event, context):
    try:
        if event["day_of_week"] == "":
            day_of_week = get_day_of_week()
        else:
            try:
                # day_of_week = int(event['day_of_week'])
                assert day_of_week >= 0
                assert day_of_week <= 6
            # except ValueError:
            #     body = json.dumps({'message': f'Invalid value for day of the week provided. Please provide a value between 0 and 6.'})
            #     return response(event, 400, body)
            except AssertionError:
                body = json.dumps({'message': f'Specify value 0 and 6 to specify a day of the week.'})
                return response(event, 400, body)    
            
        if event["week"] == "":
            week = get_day_of_week()
        else:
            try:
                # week = int(event['day_of_week'])
                assert week >= 0
                assert week <= 53
            # except ValueError:
            #     body = json.dumps({'message': f'Invalid value for week provided. Please provide an integer greater than or equal to 0, and less or equal to  53'})
            #     return response(event, 400, body)
            except AssertionError:
                body = json.dumps({'message': f'Specify provide an integer specify a week.'})
                return response(event, 400, body)
            
        database_name = event["flashcard_set"]
        number_of_words = event["number_of_words"]

    except KeyError:
        body = json.dumps({'message': f'Missing argument(s).'})
        return response(event, 400, body)
    
    selected_words = get_words(database_name, day_of_week, week, number_of_words)

    body = json.dumps({
        'cards': selected_words
    })

    return response(event, 200, body)