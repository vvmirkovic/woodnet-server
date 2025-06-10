import boto3
import csv
import sys
from botocore.exceptions import ClientError


def find_flagged_words(client, table_name):
    filter_flagged_args = {
            'TableName': table_name,
            'FilterExpression': 'attribute_exists(flagged) AND flagged = :true',
            'ExpressionAttributeValues': {
                ':true': {
                    "BOOL": True
                }
            }
    }
    
    return client.scan(**filter_flagged_args)


def add_new_word(client, table_name, id, croatian, english):
    put_item_args = {
            'TableName': table_name,
            'Item': {
                'id': {
                    'N': str(id)
                },
                'croatian': {
                    'S': croatian
                },
                'english': {
                    'S': english
                },
                'flagged': {
                    'BOOL': False
                },
                'view_count': {
                    'N': '0'
                }
            }, 
    }

    try:
        client.put_item(**put_item_args)
        print(f'"{croatian} - {english}" added to word list')
        return True
    except ClientError as e:
        if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
            return False
        else:
            raise


def update_word(client, table_name, id, croatian, english, add_new_words, unflag):
    if add_new_words and unflag:
        print('Select y for only on of add words and unflag')
        sys.exit(1)

    update_item_args = {
        'TableName': table_name,
        'Key': {
            'id': {
                'N': str(id)
            }
        },
        'UpdateExpression': 'SET croatian = :croatianValue, english = :englishValue, flagged = :flaggedValue',
        'ExpressionAttributeValues': {
            ':croatianValue': {'S': croatian},
            ':englishValue': {'S': english},
            ':flaggedValue': {'BOOL': False}
            # ':viewCountValue': {'N': '0'}
        },
        'ReturnValues': 'UPDATED_NEW'
    }

    if unflag:
        update_item_args['ExpressionAttributeValues'][':true'] = {'BOOL': True}
        update_item_args['ConditionExpression'] += 'attribute_exists(flagged) AND flagged = :true'


    if add_new_words:
        update_item_args['UpdateExpression'] += ', challenging = :challengingValue'
        update_item_args['ExpressionAttributeValues'][':challengingValue'] = {'BOOL': False}
        update_item_args['ConditionExpression'] = 'attribute_not_exists(challenging) OR attribute_not_exists(flagged)'

    try:
        response = client.update_item(**update_item_args)
        new_croatian = response['Attributes']['croatian']['S']
        new_english = response['Attributes']['english']['S']
        new_flag = response['Attributes']['flagged']['BOOL']
        new_challenging = response['Attributes']['challenging']['BOOL']

        flag_value = 'flagged' if new_flag else 'unflagged'
        challenging_value = 'challenging' if new_challenging else 'not challenging'
        print(f'"{new_croatian}" - "{new_english}" has been updated to: "{croatian}" - "{english}", {flag_value}, {challenging_value}')
        return True
    except ClientError as e:
        if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
            return False
        else:
            raise


def main():

    list_flagged_words_input = input('List flagged words (y/n): ')
    list_flagged_words = True if list_flagged_words_input == 'y' else False

    add_new_words_input = input('Add new words to the list. Ensure new words are added to the end of the csv file. Type "y" to add new words: ')
    add_new_words = True if add_new_words_input == 'y' else False

    unflag_input = input('Unflag words? Type "y" to unflag: ')
    unflag = True if unflag_input == 'y' else False
    
    session = boto3.session.Session(
        profile_name='dynamodbdev'
    )
    client = session.client('dynamodb')

    table_name = 'flashcards'
    if list_flagged_words:
        flagged_words = find_flagged_words(client, table_name)['Items']
        for word_info in flagged_words:
            croatian_word = word_info['croatian']['S']
            english_word = word_info['english']['S']
            print(f'"{croatian_word}", "{english_word}"')

    if add_new_words or unflag:
        with open('src/words.csv', 'r', encoding='utf8') as f:
            reader = csv.reader(f, delimiter=',')

            for i, row in enumerate(reader):

                # print(f'Checking desired actions for\n{i} {row}')

                modified_word = False

                # if add_new_words:
                #     modified_word = modified_word or update_word(client, table_name, i, row[0], row[1], unflag)

                # if update_words:
                #    modified_word = modified_word or update_word(client, table_name, i, row[0], row[1])

                update_word(client, table_name, i, row[0], row[1], add_new_words, unflag)
                
                # if not modified_word:
                print('Making changes' + '.' * (i//10), end='\r')


if __name__ == '__main__':
    main()
