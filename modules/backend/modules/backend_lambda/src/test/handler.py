import json
import logging 
from backend_handler import response

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    return response(event, 200, json.dumps('Hello from Lambda!'))