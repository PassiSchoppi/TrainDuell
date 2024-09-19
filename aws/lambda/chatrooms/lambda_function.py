import os
import redis
import logging
import json
import datetime

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

        if http_method == 'POST':
            # Handle POST request to set a chat_room_id-value pair
            body = json.loads(event['body'])
            chat_room_id = body.get('chat_room_id', None)
            name = body.get('name', None)
            message = body.get('message', None)

            if not chat_room_id or not name or not message:
                return {
                    'statusCode': 400,
                    'body': json.dumps('Missing chat_room_id or name or message in POST request body')
                }

            logger.info(f"Sending message: {message} name: {name} chat_room_id: {chat_room_id}")
            now = datetime.now().timestamp()
            client.zadd(f"{chat_room_id}", {message: now})

            return {
                'statusCode': 200,
                'body': json.dumps(f"Successfully sent chat message.")
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
