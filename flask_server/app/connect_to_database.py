import json, pdb, os, requests, base64
from dotenv import load_dotenv

load_dotenv(verbose=True)
DB_DNS = os.getenv("DB_DNS")

# url1 = "{}:5984/images_db/32/image".format(DNS)
# url2 = "{}:5984/images_db/37/image".format(DNS)

db = "image_comparator"
image_id = "20"
url = "{}:5984/{}/{}/image".format(DB_DNS, db, image_id)
print(f"url {url}")

# pdb.set_trace()
#response = requests.get('http://{}'.format(url), auth=('admin', 'password'))
response = requests.get('http://{}'.format(url))

if response.status_code == 200:
    #with open("/flask_server/test.png", 'wb') as f:
    with open("/flask_server/test.png", 'w') as f:
        pdb.set_trace()
        b64 = base64.b64encode(response.content)
        f.write('<img src="data:image/png;base64,{}" alt="MRI Image" />'.format(b64.decode("utf-8")))
        # f.write(response.content)
        # f.write(b64)
