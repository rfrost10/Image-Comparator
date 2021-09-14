# Image Comparator and Classifier

Purpose: Set up a static webpage and server to host classifier/pairwise comparator tasks for images 

I am not the original author of these files. This repository contains aggregated and updated files from previous developers. See acknowledgements below.


## Instructions for setup

See one of two options:

* [From Dockers](https://github.com/QTIM-Lab/Image-Comparator/tree/master/Image-Comparator-Dockerfiles)
* [From Scratch (harder)](https://github.com/QTIM-Lab/Image-Comparator/tree/master/Image-Comparator-From-Scratch)

Once setup you should have two things running:
* Web Server
* Couchdb instance

![Initial Setup](./images/initial_setup.jpg)


Before we continue we need to define some config variables so that all the internal ruby scripts can reference the right things. Find *Image-Comparator/dbutil/Configuration_template.rb*

It should have this:

```ruby
module Configuration
  DNS = 'localhost'
  IMAGES_DB = '<db_name>'
  DB_PORT = '5984'
  HTTP_PORT = '8080'
  DB_ADMIN_USER = '<admin>'
  DB_ADMIN_PASS = '<password>'
end
```
> Note: Inside docker containers, "0.0.0.0" and "localhost" now refer to the container and not the host system. Look up your system IP address with "ip addr show" or other utility so that you can specifically identify the right machien to talk to 

Create a copy called *Configuration.rb* and replace all variables with your custom configurations.


To finish configuring a single node setup, run the following;
```
# curl -X PUT http://0.0.0.0:5984/_users
curl -X PUT http://$COUCHDB_USER:$COUCHDB_PASSWORD@0.0.0.0:5984/_users
# curl -X PUT http://0.0.0.0:5984/_replicator
curl -X PUT http://$COUCHDB_USER:$COUCHDB_PASSWORD@0.0.0.0:5984/_replicator
```

To create and setup the database, run the following:
```
DB_NAME=image_comparator # same as <db_name>
# curl -X PUT http://0.0.0.0:5984/$DB_NAME # if in admin party
curl -X PUT http://$COUCHDB_USER:$COUCHDB_PASSWORD@0.0.0.0:5984/$DB_NAME
cd dbutil
# curl -X PUT http://0.0.0.0:5984/$DB_NAME/_design/basic_views -d @basic_views.json # if in admin party
curl -X PUT http://$COUCHDB_USER:$COUCHDB_PASSWORD@0.0.0.0:5984/$DB_NAME/_design/basic_views -d @basic_views.json
```

### Image-Comparator

1. Add Images to DB:

We need to add a ruby package *couchrest* to ruby. Run this command:

Docker install:
```bash
$ docker exec image-comparator-flask gem install couchrest
```
or scratch install:
```
$ sudo gem install couchrest
```

Next add images to the database with script *addImagesToDb.rb*:

In order to simplify the instructions for both docker and from scratch installs I will shell into the docker to demo, but the commands should be the same for both at this point.

> Note: In either case you should start from the directory "Image-Comparator" your local machine. This will be your ```$PWD``` and we will shell into the container and run some init scripts.

```
docker exec -it -w $PWD image-comparator-flask bash
cd dbutil; # This puts us in the directory where we can initialize the DB with certain scripts
```

Preview of working directory (docker):
```bash
root@a53f9696685a:/home/bb927/Image-Comparator# ls
Image-Comparator-Dockerfiles   dbutil     index.html                     ui
Image-Comparator-From-Scratch  deploy.rb  instatllationInstructions.txt  util
README.md                      docs       public                         vendor
about.html                     feeders    results
contact.html                   images     rubyUtils
```
> Note: when deploying the docker container, we mount "$WORKING_DIR", which is one level up from github project "Image-Comparator". This is so at the same level as the github project folder, we can put data to be loaded into couchdb and therefore via the "-v" mount we can still see that data inside the container.

Preview of working directory (scratch - should be the same as docker listing):
```bash
bb927@acadia-qtim:~/Image-Comparator$ ls
about.html    Image-Comparator-Dockerfiles   README.md
contact.html  Image-Comparator-From-Scratch  results
dbutil        images                         rubyUtils
deploy.rb     index.html                     ui
docs          instatllationInstructions.txt  util
feeders       public                         vendor
```

Continuing where we left off we need to run addImagesToDb_jkc.rb to add images. Place your imaging data in a folder at the same level as "Image-Comparator"

Ex:
```
root@a53f9696685a:/home/bb927/Image-Comparator# ls ../image-comparator-data/
MR.1.dcm   MR.15.dcm  MR.20.dcm  MR.26.dcm  MR.31.dcm  MR.37.dcm  MR.42.dcm  MR.48.dcm  MR.7.dcm
MR.10.dcm  MR.16.dcm  MR.21.dcm  MR.27.dcm  MR.32.dcm  MR.38.dcm  MR.43.dcm  MR.49.dcm  MR.8.dcm
MR.11.dcm  MR.17.dcm  MR.22.dcm  MR.28.dcm  MR.33.dcm  MR.39.dcm  MR.44.dcm  MR.5.dcm   MR.9.dcm
MR.12.dcm  MR.18.dcm  MR.23.dcm  MR.29.dcm  MR.34.dcm  MR.4.dcm   MR.45.dcm  MR.50.dcm
MR.13.dcm  MR.19.dcm  MR.24.dcm  MR.3.dcm   MR.35.dcm  MR.40.dcm  MR.46.dcm  MR.51.dcm
MR.14.dcm  MR.2.dcm   MR.25.dcm  MR.30.dcm  MR.36.dcm  MR.41.dcm  MR.47.dcm  MR.6.dcm
root@a53f9696685a:/home/bb927/Image-Comparator# 
```

```bash
cd dbutil
ruby addImagesToDb_jkc.rb Image-Comparator-Data <imageSetName> <fromCSV>
```

* \<imageFolder> is any image folder on your machine.  
* \<imageSetName> is the name for the image set.  
* \<fromCSV> ```name of csv file in imageFolder```

Sample Output:
```
root@a53f9696685a:/home/bb927/Image-Comparator/dbutil# ruby addImagesToDb_jkc.rb Image-Comparator-Data imageSet1
{"rows"=>[]}
../../image-comparator-data//MR.11.dcm
0
MR.11.dcm
dcm
../../image-comparator-data//MR.40.dcm
1
MR.40.dcm
dcm
../../image-comparator-data//MR.12.dcm

...
```

2. Add images to an Image Compare List:

```bash
ruby makeICLFromImageSetName.rb <imageSetName> <pct repeat> <list name>
```

* \<imageSetName> is the same name that was given to addImagesToDb.rb.  
* \<pct repeat> is the percentage of repeated pairs to be displayed.  
* \<list name> is a new Image Compare List name.  

3. Add a task to a user:

```bash
ruby makeTask.rb <user> <list name> <image-list-type> <task-order>
```

* \<user> is who should complete the task  
* \<list name> <list name> from above in (makeICLFromImageSetName.rb)  
* \<image-list-type> compare, OCTcompare, classify, classify_nine or quandrant.  
* \<task-order> is what precedence the image compare task takes relative to others assigned to this user.  

4. Change Image-Comparator/ui/two_image.html to have your users in this section:

```html
<!-- manually add users that you assigned tasks too in makeTasks.rb -->
<select id="username" onchange="OnSetUser(this.value)">
  <option selected="selected">Choose your user</option>
  <option value="grader1">Grader 1</option>
  <option value="grader2">Grader 2</option>
  <option value="grader3">Grader 3</option>
  <option value="grader4">Grader 4</option>
</select>
```

### Image-Classifier

Make sure the database you intend to use is already setup.
```bash
$ curl -X PUT http://admin:<password>@localhost:5984/<db_name>
$ cd /Image-Comparator/dbutil
$ curl -X PUT http://admin:<password>@localhost:5984/<db_name>/_design/basic_views -d @basic_views.json
```

1. Use addImagesToDb_jkc.rb to add an image set  
2. Use makeImageClassifyListImageSet.rb to make an image classify list  
3. Use makeTask.rb 


#### Add Images
> Should be done, but if you want to add additional images do so now

#### Make Image Classify Image List
```bash
docker exec -it image-comparator-flask bash
cd /home/bbearce/Documents/Image-Comparator/dbutil
```
and create:
```bash
ruby makeImageClassifyListImageSet.rb <imageSet> <listName> <pctRepeat>
```
Ex:
```bash
ruby makeImageClassifyListImageSet.rb imageSet1 classifyList1 0
```
#### Make Task
```bash
ruby makeTask.rb <user> <image-list-name> <image-list-type> <task-order> [<description>]
```
> [optional argment]

Ex
```bash
ruby makeTask.rb benjamin classifyList1 classify 2
```

### Grid-Classifier

#### List
```bash
python3 makeGridListFromImageSetName.py <imageSet> <listName>
```

#### Task
```bash
python3 makeTask.rb <user> <image-list-name> <image-list-type> <task-order> [<description>]
```
Ex:
```bash
python3 makeTask.py benjamin IkbeomGridList1 grid 1
```



## Acknowledgements

In the order they appear this project has been forked and added to. Yet again we fork to make a QTIM-Lab based project that will be adapted and maintained here.

1. Jayashree Kalpathy-Cramer, PhD for original source code (https://github.com/AlanCramer/Image-Comparator)  
2. Collin Wen (https://github.com/CollinWen/Image-Comparator.git)  
3. Collin Wen (https://github.com/CollinWen/Image-Comparator-Dockerfile)  
4. Jimmy chen (https://github.com/jche253/Fundus_Classifier_Comparator)  


## Contact
For questions, please contact:
* Benjamin Bearce, bbearce@gmail.com  
* Jayashree Kalpathy-Cramer, PhD kalpathy@nmr.mgh.harvard.edu  
