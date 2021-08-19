## Pre-Install Instructions

1. Set up AWS instance. A free tier server is adequate for small scale deployment. I also recommend setting up an SFTP client such as FileZilla for easier file transfer (will require your public IPv4/DNS and a security key .pem file)
2. SSH to your server using your custom command/security key provided by AWS.

## Instructions for setup

### Initial setup

> Make sure you are in your home directory *~/home/ubuntu* or *~/home/\<user>* if on a local machine

1. ```git clone https://github.com/QTIM-Lab/Image-Comparator.git```  

2. ```cd Image-Comparator``` 

3. Install these libraries if your system doesn't already have them (more necesary for docker containers as they are light weight with minimal installed software).

> AWS VMs have all but ruby

```bash
apt-get install -y git
apt-get install -y python
apt-get install -y ruby
apt-get install -y vim
apt-get install -y curl
```

4. Deploy server using the following:

*python2*  
```bash
$ python -m SimpleHTTPServer 8080
Serving HTTP on 0.0.0.0 port 8080 (http://0.0.0.0:8080/) ...
```

*python3*
```bash
$ python3 -m http.server 8080
Serving HTTP on 0.0.0.0 port 8080 (http://0.0.0.0:8080/) ...
```

You should see this html indicating success:
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">

    <title>Image Comparator</title>

    <style>
        body {
            margin:4%;
        }
    </style>

<link rel="shortcut icon" type="image/png" href="/images/favicon-32x32.png">

</head>

<body>

    <h2>Image Comparator</h2>

    <br>

    <label> To see the image comparison user interface to compare two knee images go </label>
    <a href = "ui/two_image.html"> here</a>

    <br>

    <label> To see the image classification go</label>
    <a href = "ui/image_class.html"> here</a>

    <p></p>

    <!--
    <label> To see the image comparison user interface to compare two OCT scans go </label>
    <a href = "ui/oct_two_image.html"> here</a>
    -->

</body>

</html>
```


> Without the use of *tmux* or *screen* your server will stop when the terminal is terminated. 

To use screen perform the following:

```bash
$ screen -S http_server
```

Once in the screen run ```python3 -m http.server 8080``` and then use *cntrl+a, d* to exit screen leaving it running. Finally use ```screen -ls``` to see available screens:

```bash
$ screen -ls
There is a screen on:
    13545.http_server   (11/08/19 20:28:20) (Detached)
1 Socket in /run/screen/S-ubuntu.
```

Now anytime you need to get into the screen to stop the server run ```screen -r http_server```, and you will be dropped back into the screen.

### Couchdb Setup

To install couchdb, run the following:
> [couchdb](https://docs.couchdb.org/en/stable/install/unix.html)
```bash
sudo apt-get install -y gnupg ca-certificates;

echo "deb https://apache.bintray.com/couchdb-deb bionic main" \
  | sudo tee /etc/apt/sources.list.d/couchdb.list;

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys \
  8756C4F765C9AC3CB6B85D62379CE192D401AB61;

sudo apt update

sudo apt install -y couchdb
```

Use the following configurations:
* 1: single node
* 0.0.0.0 bind address
* (password)

To ensure that the database is accessible locally, check the following locations to make sure that all instances of bind_address are set to '0.0.0.0' (127.0.0.1 means that the database is only accessible on the host machine)
* /opt/couchdb/etc/local.ini
* /opt/couchdb/etc/default.ini
* /opt/couchdb/etc/default.d/10-bind-address.ini

Next confirm that CORS (cross-origin resource sharing) is enabled in the following locations
* /opt/couchdb/etc/default.ini
    * enable_cors = true
    * under '[cors]', add the following:
    * origins = *
    * credentials = true
    * methods = GET, PUT, POST, HEAD, DELETE
    * headers = accept, authorization, content-type, origin, referer, x-csrf-token
* /opt/couchdb/etc/local.ini
    * under '[httpd]', add the following:
    * enable_cors = true
    * at the bottom, add:
    * [cors]
    * origins = *
    * credentials = true
    * methods = GET, PUT, POST, HEAD, DELETE


Bash to do the above:
```bash
# default.ini replacements
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /opt/couchdb/etc/default.ini;
sudo sed -i 's/;origins = \*/origins = \*/g' /opt/couchdb/etc/default.ini;
sudo sed -i 's/credentials = false/credentials = true/g' /opt/couchdb/etc/default.ini;
sudo sed -i 's/enable_cors = false/enable_cors = true/g' /opt/couchdb/etc/default.ini;
sudo sed -i 's/; methods =/methods = GET, PUT, POST, HEAD, DELETE/g' /opt/couchdb/etc/default.ini;
sudo sed -i 's/; headers =/headers = accept, authorize, content-type, origin, referer, x-csrf-token/g' /opt/couchdb/etc/default.ini;

# local.ini replacements
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /opt/couchdb/etc/local.ini;
sudo sed -i '/\[httpd\]/a enable_cors = true' /opt/couchdb/etc/local.ini;
printf '[cors]\norigins = *\ncredentials = true\nmethods = GET, PUT, POST, HEAD, DELETE' | sudo tee -a /opt/couchdb/etc/local.ini

# 10-bind-address.ini
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /opt/couchdb/etc/default.d/10-bind-address.ini;
```

Once you've confirmed the bind_address and CORS are configured properly, you must restart the couchdb server by using the following command:
```
service couchdb restart
```

### Test Connections

If you have opened ports 8080 (for the http site) and 5984 (couchdb) then you should be able to navigate to these urls:

```
http://<aws-ip-address--or--dns>:8080
http://<aws-ip-address--or--dns>:5984
```

or

```
http://<local-ip-address>:8080
http://<local-ip-address>:5984
```

or

```
http://<localhost>:8080
http://<localhost>:5984
```
> Make sure ports 8080 and 5984 are open in AWS\Azure\local dev or you won't see the home page for the website or the welcome json from couchdb.

## Instructions for use
