# require 'net/http'
# require 'uri'
# require 'json'

import os, sys, requests, json, couchdb, uuid, pdb
from datetime import datetime, timezone, timedelta
from dotenv import load_dotenv



load_dotenv("../flask_server/.env",verbose=True)
 
DB_ADMIN_USER = os.getenv("DB_ADMIN_USER")
DB_ADMIN_PASS = os.getenv("DB_ADMIN_PASS")
DNS = os.getenv("DNS")
DB_DNS = os.getenv("DB_DNS")
IMAGES_DB = os.getenv("IMAGES_DB")
DB_PORT = os.getenv("DB_PORT")
HTTP_PORT = os.getenv("HTTP_PORT")
ADMIN_PARTY = os.getenv("ADMIN_PARTY")

# https://couchdb-python.readthedocs.io/en/latest/getting-started.html
couch = couchdb.Server(f'http://{DNS}:{DB_PORT}')

# couch package ex for later
    # db = couch[IMAGES_DB]
    # imageIDs = [int(row['id']) for row in db.view('_design/basic_views/_view/imageSet2ImageId')]
    # imageIDs.sort()
    # imageIDs = [str(i) for i in imageIDs]

def getURL(imageSet: str) -> str:

    url = f"http://{DNS}:{DB_PORT}/{IMAGES_DB}"
    view = f'/_design/basic_views/_view/imageSet2ImageId?key="{imageSet}"'
    URL = url + view
    return URL

def getImageIDs(url: str) -> list:
    if ADMIN_PARTY == False:
        response = requests.get(url, auth=(DB_ADMIN_USER, DB_ADMIN_PASS))
    else:
        response = requests.get(url)
    response = response.content.decode('utf-8')
    response = json.loads(response)    
    imageIDs = [int(row['id']) for row in response['rows']]
    imageIDs.sort()

    return imageIDs

def makeList(listName: str, imageIDs: list) -> None:
    uid = uuid.uuid1()
    t = datetime.now() - timedelta(hours=4)
    obj = {"type":"image_grid_list",
           "list_name": listName,
           "unique_image_count":len(imageIDs),
           "count":len(imageIDs), # If we add pctRepeat in this could be larger
           "list":imageIDs,
           "time_added":t.strftime('%Y-%m-%d %H:%M:%S')}
    db = couch[IMAGES_DB]
    # pdb.set_trace()
    print(f"Created Grid List: {listName}")
    doc_id, doc_rev = db.save(obj)
    


def main(imageSet: str, listName: str):
    url = getURL(imageSet)
    imageIDs = getImageIDs(url)
    makeList(listName, imageIDs)



if __name__ == "__main__":
    try:
        main(sys.argv[1], sys.argv[2])
    except IndexError as err:
        print(f"""
        Error: {err}, and probably means you 
        didn't provide <imageSet> or <listName>
        """)
    


