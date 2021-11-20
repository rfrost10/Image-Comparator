import os, sys, requests, json, couchdb, uuid, pdb, pprint as pp
from datetime import datetime, timezone, timedelta
from dotenv import load_dotenv

load_dotenv("../flask_server/.env",verbose=True)
 
DB_ADMIN_USER = os.getenv("DB_ADMIN_USER")
DB_ADMIN_PASS = os.getenv("DB_ADMIN_PASS")
DNS = os.getenv("DNS")
IMAGES_DB = os.getenv("IMAGES_DB")
DB_PORT = os.getenv("DB_PORT")
HTTP_PORT = os.getenv("HTTP_PORT")
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

def makeTask(user: str,imageListName: str, imageListType: str, taskOrder: int) -> None:
    t = datetime.now() - timedelta(hours=4)
    obj = {"type":"task",
           "task_type":imageListType, 
           "list_name": imageListName,
           "task_order": taskOrder,
           "user":user,
           "time_added":t.strftime('%Y-%m-%d %H:%M:%S'),
           "current_idx":0,
           "completed":False}
    db = couch[IMAGES_DB]
    # pdb.set_trace()
    doc_id, doc_rev = db.save(obj)
    print(pp.pprint(f"created object {obj}"))
    
def main(user: str,imageListName: str, imageListType: str, taskOrder: int):
    # uid = uuid.uuid1()
    # url = getURL(str(uid))
    # pdb.set_trace()
    makeTask(user, imageListName, imageListType, taskOrder)



if __name__ == "__main__":
    try:
        main(sys.argv[1], sys.argv[2],sys.argv[3],sys.argv[4])
    except IndexError as err:
        print(f"""
        Error: {err}, and probably means you 
        didn't provide <user> or <imageListName> <imageListType> <taskOrder>
        """)


