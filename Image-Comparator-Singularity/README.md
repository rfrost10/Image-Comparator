### Deploy couchdb docker image
Decide on a place to store the couchdb data. ```/opt/couchdb/data``` is where a normal couchdb installs will store data so don't use this directory in a docker mount unless you don't have couchdb installed on the machine already.
```
APP_NAME=default
sudo mkdir -p /opt/couchdb/data/$APP_NAME # if it doesn't exist already

# Change in production
COUCHDB_USER=admin
COUCHDB_PASSWORD=password
COUCH_PORT=5984


docker run \
 -p $COUCH_PORT:5984 \
 --name image-comparator-couchdb-$APP_NAME \
 -v /opt/couchdb/data/$APP_NAME:/opt/couchdb/data \
 -d \
 -e COUCHDB_USER=$COUCHDB_USER \
 -e COUCHDB_PASSWORD=$COUCHDB_PASSWORD \
 couchdb:latest

# Create sandbox
```bash
singularity build --sandbox s_kmotion_couchdb couchdb.sif
```

```bash
singularity shell \
singularity shell \
  --fakeroot \
  --writable \
  --net \
  --env COUCHDB_USER=$COUCHDB_USER \
  --env COUCHDB_PASSWORD=$COUCHDB_PASSWORD \
  -B /local_mount/space/carlsbad/3/users/bb927/Image-Comparator/couchdb_database:/opt/couchdb \
  s_kmotion_couchdb/

```

```bash
chown -R couchdb:couchdb /opt/couchdb/data
singularity run \
  couchdb.sif
 

singularity run \
  -B /local_mount/space/carlsbad/3/users/bb927/Image-Comparator/couchdb_database:/opt/couchdb/data \
  couchdb.sif
  
-B $PWD/couchdb_database:/opt/couchdb/data \
```

> Note you can't make requests to this container wihtout making sure that CORS (cross-origin resource sharing) is enabled:

Once logged into couchdb goto settings to enable CORS:

![Initial Setup](../readme_images/couchdb_cors.jpg)

Create an Admin (if you delete them):
![create couch admin](../readme_images/couchdb_create_admin.jpg)

Debugging...

To shell into this container:
```bash
docker exec -it image-comparator-couchdb bash
```

To stop container (if needed):
```bash
docker stop image-comparator-couchdb
```

### Set up Image-Comparator in a Docker Container Using Flask

We will be using the singularity.recipe file in ```Image-Comparator-Singularity```.

#### Build the container

Build a new image for flask and serve in the context of the flask_server folder:
```bash
cd Image-Comparator-Singularity
MACHINE_PORT="5900"

singularity build --fakeroot IC.simg singularity.recipe

cd ../

WKDIR=$PWD # this should be where git repo was cloned
WKDIR=/local_mount/space/carlsbad/3/users/bb927/Image-Comparator/flask_server

singularity run \
  -B $WKDIR:$WKDIR \
  --env FLASK_APP=flask_server/image_comparator \
  --env MACHINE_PORT=$MACHINE_PORT \
  --env LC_ALL=C.UTF-8 \
  Image-Comparator-Singularity/IC.simg 
```

#### Debugging flask server container
```bash
singularity shell \
  -B $WKDIR:$WKDIR \
  --env FLASK_APP=flask_server/image_comparator \
  --env MACHINE_PORT=$MACHINE_PORT \
  --env LC_ALL=C.UTF-8 \
  Image-Comparator-Singularity/IC.simg

# cd flask_server; # If above isn't working, and keep in mind if you are here then FLASK_APP=image_comparator

flask run --port $MACHINE_PORT --host 0.0.0.0
```

