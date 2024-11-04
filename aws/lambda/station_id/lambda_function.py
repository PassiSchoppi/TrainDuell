import json
import bisect
from sorted_station_list import sorted_data  # Importing the sorted data

def lambda_handler(event, context):
    # Step 1: Parse the search term from the POST request body
    try:
        body = json.loads(event['body'])
        search_term = body.get("search_term", "").strip()
        if not search_term:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Search term is required."})
            }
    except (json.JSONDecodeError, KeyError):
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Invalid request format. Must be JSON with 'search_term'."})
        }
    # Step 2: Find the index of the first matching prefix
    start_idx = bisect.bisect_left(sorted_data, (search_term, ))
    # Step 3: Collect all tuples starting with the search term as a prefix
    matching_entries = []
    for name, id_num in sorted_data[start_idx:]:
        if name.startswith(search_term):
            matching_entries.append((name, id_num))
        else:
            break  # Stop once names no longer match the prefix
    # Step 4: Return matching entries as JSON response
    return {
        "statusCode": 200,
        "body": json.dumps({"results": matching_entries})
    }
