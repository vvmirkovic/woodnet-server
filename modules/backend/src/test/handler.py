import logging 

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    print("Hello world")