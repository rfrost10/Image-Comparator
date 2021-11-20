### Deploy couchdb docker image
Decide on a place to store the couchdb data. ```/opt/couchdb/data``` is where a normal couchdb installs will store data so don't use this directory in a docker mount unless you don't have couchdb installed on the machine already.
```
mkdir -p /opt/couchdb/data # if it doesn't exist already

COUCHDB_USER=admin
COUCHDB_PASSWORD=password
COUCH_PORT=5984


docker run \
 -p $COUCH_PORT:5984 \
 --name image-comparator-couchdb \
 -v /opt/couchdb/data:/opt/couchdb/data \
 -d \
 -e COUCHDB_USER=$COUCHDB_USER \
 -e COUCHDB_PASSWORD=$COUCHDB_PASSWORD \
 couchdb:latest
```

> Note you can't make requests to this container wihtout making sure that CORS (cross-origin resource sharing) is enabled:

Once logged into couchdb goto settings to enable CORS:

![Initial Setup](../images/couchdb_cors.jpg)

Create an Admin (if you delete them):
![create couch admin](../images/couchdb_create_admin.jpg)

Debugging...

To shell into this container:
```
docker exec -it image-comparator-couchdb bash
```

To stop container (if needed):
```
docker stop image-comparator-couchdb
```

### Setting up Image-Comparator in a Docker Container Using Flask

We will be using the *Dockerfile_flask* file in ```Image-Comparator-Dockerfiles```.

#### Build the container

Build a new image for flask and serve in the context of the flask_server folder:
```bash
cd Image-Comparator-Dockerfiles
CONTAINER_NAME=image-comparator
SUPPLEMENTARY_NAME="" # optional for multiple containers
CONTAINER_TAG=flask
MACHINE_PORT="8080"

docker build . -f Dockerfile_flask --force-rm -t $CONTAINER_NAME:$CONTAINER_TAG

cd ../

# sometimes you will need ```--network="host"```
# soln to the host issue is also solved more appropriately with: what is in the following code
# source: https://stackoverflow.com/questions/38344941/two-dockers-container-see-each-others-in-the-same-machine
# if you can't resolve DNS. Not the most secure though...

docker run \
  -it \
  --rm \
  --network="host" \
  -p $MACHINE_PORT:8080 \
  -v $PWD/flask_server:/flask_server \
  -v $PWD:$PWD \
  -w /flask_server \
  --name "$CONTAINER_NAME""-""$CONTAINER_TAG""$SUPPLEMENTARY_NAME" \
  image-comparator:flask
```

#### Pip install requirements
```bash
pip3 install -r requirements.txt
```

#### Run flask server
```bash
flask run --port 8080 --host 0.0.0.0
```

