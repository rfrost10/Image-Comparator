import os, sys, requests, json, couchdb, uuid, pdb, pprint as pp
from datetime import datetime, timezone, timedelta
from dotenv import load_dotenv

load_dotenv("flask_server/.env", verbose=True)

DB_ADMIN_USER = os.getenv("DB_ADMIN_USER")
DB_ADMIN_PASS = os.getenv("DB_ADMIN_PASS")
DNS = os.getenv("DNS")
IMAGES_DB = os.getenv("IMAGES_DB")
DB_PORT = os.getenv("DB_PORT")
ADMIN_PARTY = True if os.getenv("ADMIN_PARTY") == 'True' else False

# https://couchdb-python.readthedocs.io/en/latest/getting-started.html
if ADMIN_PARTY:
    couch = couchdb.Server(f'http://{DNS}:{DB_PORT}')
else:
    couch = couchdb.Server(f'http://{DB_ADMIN_USER}:{DB_ADMIN_PASS}@{DNS}:{DB_PORT}')

# couch package ex for later
# db = couch[IMAGES_DB]
# imageIDs = [int(row['id']) for row in db.view('_design/basic_views/_view/imageSet2ImageId')]
# imageIDs.sort()
# imageIDs = [str(i) for i in imageIDs]

# def getURL(uuid: str) -> str:
#     url = f"http://{DNS}:{DB_PORT}/{IMAGES_DB}"
#     view = f'/{uuid}'
#     URL = url + view
#     return URL

def testt(): # Delete soon 12.7.2021
    print("testt")

def makeTask(user: str, imageListName: str, imageListType: str, taskOrder: int, description: str) -> None:
    t = datetime.now() - timedelta(hours=4)
    obj = {"type": "task",
           "task_type": imageListType,
           "list_name": imageListName,
           "description":description,
           "task_order": taskOrder,
           "user": user,
           "time_added": t.strftime('%Y-%m-%d %H:%M:%S'),
           "current_idx": 0,
           "completed": False}
    db = couch[IMAGES_DB]
    doc_id, doc_rev = db.save(obj) # currently doc_id, doc_rev unused
    print(pp.pprint(f"created object {obj}"))

def main(user: str, imageListName: str, imageListType: str, taskOrder: int, description: str = "none"):
    # pdb.set_trace()
    makeTask(user, imageListName, imageListType, taskOrder, description)

if __name__ == "__main__":
    try:
        try:
            main(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
            print(f"* Creating {sys.argv[3]} task with description {sys.argv[5]}. *")
        except:
            main(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
            print(f"* Creating {sys.argv[3]} task. *")
    except IndexError as err:
        print(f"""
        Error: {err}, and probably means you 
        didn't provide <user>, <imageListName>, <imageListType>, <taskOrder>, with optional [<description>]
        """)
