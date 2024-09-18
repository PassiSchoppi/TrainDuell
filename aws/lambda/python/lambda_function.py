import os
import redis
import logging
import json

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Retrieve Redis connection details from environment variables
URL = os.getenv('URL', 'your-redis-endpoint')
REDIS_PORT = os.getenv('REDIS_PORT', 6379)
REDIS_PASSWORD = os.getenv('REDIS_PASSWORD', None)

def connect_to_redis():
    try:
        logger.info(f'Connecting to Redis at {URL}:{REDIS_PORT}')
        # Connect to Redis instance
        client = redis.StrictRedis(
            host=URL,
            port=int(REDIS_PORT),
            password=REDIS_PASSWORD,
            ssl=True,  # Enable SSL if required (e.g., ElastiCache)
            decode_responses=True
        )
        # Ping the Redis server to test the connection
        ping_response = client.ping()
        if ping_response:
            logger.info("Successfully connected to Redis!")
        return client
    except Exception as e:
        logger.error(f"Failed to connect to Redis: {e}")
        raise

def lambda_handler(event, context):
    try:
        # Connect to the Redis instance
        client = connect_to_redis()

        # Determine the HTTP method (GET or POST)
        http_method = event['httpMethod']

        if http_method == 'GET':
            # Handle GET request to retrieve the value for a given key
            key = event['queryStringParameters'].get('key', None)
            if not key:
                return {
                    'statusCode': 400,
                    'body': json.dumps('Missing key parameter in GET request')
                }

            logger.info(f"Getting value for key: {key}")
            value = client.get(key)

            if value:
                return {
                    'statusCode': 200,
                    'body': json.dumps({key: value})
                }
            else:
                return {
                    'statusCode': 404,
                    'body': json.dumps(f"Key '{key}' not found in Redis")
                }

        elif http_method == 'POST':
            # Handle POST request to set a key-value pair
            body = json.loads(event['body'])
            key = body.get('key', None)
            value = body.get('value', None)

            if not key or not value:
                return {
                    'statusCode': 400,
                    'body': json.dumps('Missing key or value in POST request')
                }

            logger.info(f"Setting key: {key} with value: {value}")
            client.set(key, value)

            return {
                'statusCode': 200,
                'body': json.dumps(f"Successfully set key '{key}' with value '{value}'")
            }

        else:
            return {
                'statusCode': 405,
                'body': json.dumps(f"Method {http_method} not allowed")
            }

    except Exception as e:
        logger.error(f"Error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Failed to process request: {str(e)}")
        }
