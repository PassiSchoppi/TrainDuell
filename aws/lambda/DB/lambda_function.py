import requests
import xml.etree.ElementTree as ET
import json

def lambda_handler(): #event, context

    station_id = '8000105' # event['queryStringParameters']['station_id']
    date = '241016' # event['queryStringParameters']['date']
    time = '11' # event['queryStringParameters']['time']


    url = f"https://apis.deutschebahn.com/db-api-marketplace/apis/timetables/v1/plan/{station_id}/{date}/{time}"

    headers = {
        "DB-Client-Id": "a3e5f338d55d9eed4e7103f35100dcc7",
        "DB-Api-Key": "2503dd2b3a75a3aa03b92ce395625ddc",
        "accept": "application/xml"
    }

    response = requests.get(url, headers=headers)

    if response.status_code != 200:
        return {
            'statusCode': response.status_code,
            'body': json.dumps({'message': 'Request failed'})
        }

    root = ET.fromstring(response.text)

    def print_element(element):
        result = []
        for train in element:
            train_info = {}
            train_info['zug_id'] = train.attrib['id']
            train_info['zug'] = f"{train.find('tl').attrib['c']} {train.find('tl').attrib['n']}"
            train_info['abfahrt_von'] = root.attrib.get('station', 'Unbekannt')

            try:
                train_info['vergangene_halte'] = train.find('ar').attrib['ppth'].split('|')
            except:
                train_info['vergangene_halte'] = 'Der Zug startet hier.'

            try:
                train_info['kommende_halte'] = train.find('dp').attrib['ppth'].split('|')
            except:
                train_info['kommende_halte'] = 'Der Zug endet hier.'

            result.append(train_info)

        return result

    train_data = print_element(root)

    return {
        'statusCode': 200,
        'body': json.dumps(train_data)
    }

lambda_handler()