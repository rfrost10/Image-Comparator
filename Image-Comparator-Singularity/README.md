# Deploy couchdb singularity container

Decide on a place to store the couchdb data. ```/opt/couchdb/data``` is where a normal couchdb installs will store data (in the container). For isngularity we work out of sandboxes so this will reside in the sandbox.

## Preparation
> Note these are really duplicated instructions from [Martinos Singularity and Compute Instructions](https://www.nmr.mgh.harvard.edu/martinos/userInfo/computer/
1. **If needed**, symlink your `~/.singularity` directory to be somewhere else so that you don't fill up your home directory (quota may be small)
docker.php).

```bash
TMP_FILES=/path/to/your/location

cd ${TMP_FILES}
mkdir singularity
rm -rf ~/.singularity
ln -s ${TMP_FILES}/singularity ~/.singularity
```

2. Create singularity `tmp` and `cache` directories - see e.g. https://www.nmr.mgh.harvard.edu/martinos/userInfo/computer/docker.php

```bash
mkdir -p /scratch/$USER/{tmp,cache}
export SINGULARITY_TMPDIR=/scratch/$USER/tmp
export SINGULARITY_CACHEDIR=/scratch/$USER/cache
```

## Get couchdb:latest from Docker Hub
```bash
SERVER=carlsbad.nmr.mgh.harvard.edu #serena
ssh $SERVER
```

Once in:
```bash
WKDIR=/local_mount/space/carlsbad/3/users/bb927/Image-Comparator # /local_mount/space/serena/2/users/dave
cd $WKDIR
```

Grab and pull the couchdb image. We will store in the Singularity notes area:
```bash
cd Image-Comparator-Singularity
singularity pull couchdb.sif docker://couchdb:latest
```

## Create sandbox
```bash
INSTANCE=_instance_1 # use if you want to make multiple instances
SANDBOX_NAME=couchdb_sandbox$INSTANCE
singularity build --sandbox $SANDBOX_NAME couchdb.sif
```

## Set an open port you can use
couchdb uses port 5984 by default but you may not be able to use that

```bash
OPEN_PORT=5900 # 10105
```

## Some settings
Change the username and password

```bash
COUCHDB_USER=admin
COUCHDB_PASSWORD=password

INST_NAME=couchdb$INSTANCE
```

## Start a singularity instance
So that the instance starts couchdb in the background (equivalent to docker detached `-d` mode)

The `runscript` launches the couchdb server. `singularity instance start` runs
`startscript`, which is initially empty. So to start the server, we'll run append a line to `startscript` to call `runscript`, which means that the server will start in the background after starting the instance.

```console
$ echo "/.singularity.d/runscript" >> $SANDBOX_NAME/.singularity.d/startscript

$ singularity instance start --fakeroot --writable \
    --net --network-args "portmap=${OPEN_PORT}:5984/tcp" \
    --env COUCHDB_USER=$COUCHDB_USER \
    --env COUCHDB_PASSWORD=$COUCHDB_PASSWORD \
    $SANDBOX_NAME/ \
    ${INST_NAME}
[WARN  tini (14)] Tini is not running as PID 1 and isn't registered as a child subreaper.
Zombie processes will not be re-parented to Tini, so zombie reaping won't work.
To fix the problem, use the -s option or set the environment variable TINI_SUBREAPER to register Tini as a child subreaper, or run Tini as PID 1.

INFO:    instance started successfully
```

## Test the database connection

```console
$ curl $SERVER:$OPEN_PORT
{"couchdb":"Welcome","version":"3.2.2","git_sha":"d5b746b7c","uuid":"ce86c3d679339d8bb6399d12c500b40e","features":["access-ready","partitioned","pluggable-storage-engines","reshard","scheduler"],"vendor":{"name":"The Apache Software Foundation"}}
```

This shows that the server is running!

Alternatives:

Examples:
```bash
curl 0.0.0.0:$OPEN_PORT
curl 127.0.0.1:$OPEN_PORT
```

## Get to the website
Navigate to e.g. http://$SERVER:$OPEN_PORT/_utils

If this is a Martinos machine, you'll need to be on the network or on the VPN.

At that page you should be able to log in with the user=COUCHDB_USER and pw=COUCHDB_PASSWORD

> This may still not work. If it doesn't you may need to setup an ssh tunnel for your local machine to map the port where this is deployed to a port of your local. Here is an example

```bash
$ sudo ssh -N -f -L localhost:$OPEN_PORT:localhost:$OPEN_PORT bb927@$SERVER
```

More notes here [https://ljvmiranda921.github.io/notebook/2018/01/31/running-a-jupyter-notebook/](https://ljvmiranda921.github.io/notebook/2018/01/31/running-a-jupyter-notebook/)

This maps the localhost of both machines together and 

## Dealing with the singularity instance
Show running instances

```console
$ singularity instance list
INSTANCE NAME    PID       IP            IMAGE
couchdb_inst     241595    10.23.0.38    /local_mount/space/serena/2/users/dave/couchdb/couchdb_sandbox
```

Stop the singularity instance

```console
$ singularity instance stop ${INST_NAME}
INFO:    Stopping couchdb_inst instance of /local_mount/space/serena/2/users/dave/couchdb/couchdb_sandbox (PID=241595)
```

Check where output is written
```console
$ singularity instance list -l ${INST_NAME}
INSTANCE NAME    PID       LOGS
couchdb_inst     241595    /homes/2/dave/.singularity/instances/logs/serena.nmr.mgh.harvard.edu/dave/couchdb_inst.err
                           /homes/2/dave/.singularity/instances/logs/serena.nmr.mgh.harvard.edu/dave/couchdb_inst.out
```
> Note that this user's `~/.singularity` is symlinked to be somewhere else

**Be careful** - a lot of output goes to the .err file, so eventually this could fill up your disk space. Be sure to periodically check the space it makes.

> Note you can't make requests to this container without making sure that CORS (cross-origin resource sharing) is enabled:

Once logged into couchdb goto settings to enable CORS:

![Initial Setup](../readme_images/couchdb_cors.jpg)

Create an Admin (if you delete them):
![create couch admin](../readme_images/couchdb_create_admin.jpg)


> Extra information
FYI without the `startscript` modification above, would need to do the following.
The disadvantage of this is that it would just run in the terminal, instead of in the background.

```bash
singularity instance start --fakeroot --writable \
    --net --network-args "portmap=${OPEN_PORT}:5984/tcp" \
    --env COUCHDB_USER=$COUCHDB_USER \
    --env COUCHDB_PASSWORD=$COUCHDB_PASSWORD \
    $SANDBOX_NAME/ \
    ${INST_NAME}

singularity run instance://${INST_NAME}
```

To shell into this container for debugging:

```bash
singularity shell instance://${INST_NAME}
```

# Set up Image-Comparator in a Singularity Container Using Flask

We will be using the singularity.recipe file in ```Image-Comparator-Singularity```.

## Build the container

Build a new image for flask and serve in the context of the flask_server folder and get yourself into the "Image-Comparator-Singularity" directory:

```bash
cd Image-Comparator-Singularity
UI_PORT="5902" # For app not couchdb

singularity build --fakeroot IC$INSTANCE.simg singularity.recipe

cd ../

WKDIR=$PWD # this should be where git repo was cloned
WKDIR=/local_mount/space/carlsbad/3/users/bb927/Image-Comparator/flask_server

singularity run \
  -B $WKDIR:$WKDIR \
  --env FLASK_APP=flask_server/image_comparator \
  --env LC_ALL=C.UTF-8 \
  Image-Comparator-Singularity/IC$INSTANCE.simg $UI_PORT
```

> Note with a new port you may need this again:
```bash
$ sudo ssh -N -f -L localhost:$UI_PORT:localhost:$UI_PORT bb927@$SERVER
```

## Debugging flask server container
```bash
singularity shell \
  -B $WKDIR:$WKDIR \
  --env FLASK_APP=flask_server/image_comparator \
  --env UI_PORT=$UI_PORT \
  --env LC_ALL=C.UTF-8 \
  Image-Comparator-Singularity/IC$INSTANCE.simg

# cd flask_server; # If above isn't working, and keep in mind if you are here then FLASK_APP=image_comparator

flask run --port $UI_PORT --host 0.0.0.0
```
