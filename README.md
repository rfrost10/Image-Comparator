# Image Comparator and Classifier

Purpose: Set up a static webpage and server to host classifier/pairwise comparator tasks for images 

I am not the original author of these files. This repository contains aggregated and updated files from previous developers. See acknowledgements below.


## Instructions for setup

* [Installation](https://github.com/QTIM-Lab/Image-Comparator/tree/master/Image-Comparator-Dockerfiles)

Once setup you should have two things running:
* Web Server
* Couchdb instance

![Initial Setup](./readme_images/initial_setup.jpg)


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
  ADMIN_PARTY = false
end
```

Create a copy called *Configuration.rb* and replace all variables with your custom configurations.


To finish configuring a single node setup, run the following;
```
DB_PORT=5984
COUCHDB_USER=admin
COUCHDB_PASSWORD=password

curl -X PUT http://$COUCHDB_USER:$COUCHDB_PASSWORD@0.0.0.0:$DB_PORT/_users
curl -X PUT http://$COUCHDB_USER:$COUCHDB_PASSWORD@0.0.0.0:$DB_PORT/_replicator

# Use below if in admin party mode:
# curl -X PUT http://0.0.0.0:$DB_PORT/_users
# curl -X PUT http://0.0.0.0:$DB_PORT/_replicator
```

To create and setup the database, run the following:
```
DB_NAME=image_comparator 

curl -X PUT http://$COUCHDB_USER:$COUCHDB_PASSWORD@0.0.0.0:$DB_PORT/$DB_NAME

# Admin party:
# curl -X PUT http://0.0.0.0:$DB_PORT/$DB_NAME
```

Add some views to the db:
```
cd dbutil

curl -X PUT http://$COUCHDB_USER:$COUCHDB_PASSWORD@0.0.0.0:$DB_PORT/$DB_NAME/_design/basic_views -d @basic_views.json

# Admin party:
# curl -X PUT http://0.0.0.0:$DB_PORT/$DB_NAME/_design/basic_views -d @basic_views.json

cd ../ # return to main directory
```

### Add Images to DB:

```
docker exec -it -w $PWD image-comparator-flask bash
cd dbutil;
```

Place your imaging data in "Image-Comparator-Data". 

Ex:
```
root@a53f9696685a:/home/bb927/Image-Comparator# ls ../Image-Comparator-Data/
MR.1.dcm   MR.2.dcm  MR.3.dcm  MR.4.dcm
```


> If you want to supply the class of the image ahead of time, supply a csv in "Image-Comparator-Data" with image name and id like so:
```
image,class
MR.1.dcm,class_a
MR.2.dcm,class_b
MR.3.dcm,class_c
MR.4.dcm,class_a
...
```

Run addImagesToDb_jkc.rb to add images:

> < required arguments >

> [optional arguments]
```bash
ruby addImagesToDb_jkc.rb <path to Image-Comparator-Data> <imageSetName> [<fromCSV>]
```

Ex:
```
ruby addImagesToDb_jkc.rb ../Image-Comparator-Data mimicMIDRCtrain training_classification.csv
ruby addImagesToDb_jkc.rb ../Image-Comparator-Data mimicMIDRCvalidation validation_classification.csv
ruby addImagesToDb_jkc.rb ../Image-Comparator-Data mimicMIDRCtest test_classification.csv
```

* \<imageFolder> Image-Comparator-Data, but could be user specified.  
* \<imageSetName> is the name for the image set.  
* \<fromCSV> ```name of optional csv file in imageFolder```

Sample Output:
```
root@a53f9696685a:/home/bb927/Image-Comparator/dbutil# ruby addImagesToDb_jkc.rb Image-Comparator-Data imageSet1
{"rows"=>[]}
../../image-comparator-data//MR.1.dcm
0
MR.1.dcm
dcm
../../image-comparator-data//MR.2.dcm
1
MR.2.dcm
dcm
../../image-comparator-data//MR.3.dcm
...
```

### Change flask_server/app/templates/app_template.html to have your users in this section:

```html
<!-- manually add users that you assigned tasks too in makeTasks.rb -->
<select id="username" onchange="{{ app_config.app }}TaskFeeder.OnSetUser(this.value)">
    <option selected="selected">Choose your user</option>
    <option value="Benjamin">Benjamin</option>
</select>
```

*With the app running, image list created and users in the drop down, you can proceed to configuring image lists for use within specific apps below*

## Apps

> You need to have created an image set already with "addImagesToDb_jkc.rb". Go back to the "Add Images to DB" section above.

> Shell into container if you haven't already and make your way to "./dbutil"
```bash
docker exec -it image-comparator-flask bash
```

### Image-Comparator

#### Make Image Compare List:

```bash
ruby makeICLFromImageSetName.rb <imageSetName> <pct repeat> <list name>
```

Ex:
```
ruby makeICLFromImageSetName.rb <imageSetName> <pct repeat> <list name>
ruby makeICLFromImageSetName.rb <imageSetName> <pct repeat> <list name>
ruby makeICLFromImageSetName.rb <imageSetName> <pct repeat> <list name>
```

* \<imageSetName> is the same name that was given to addImagesToDb.rb. This is you image set.  
* \<pct repeat> is the percentage of repeated pairs to be displayed.  
* \<list name> is a new Image Compare List name.  

#### Add a task to a user:

```bash
ruby makeTask.rb <user> <list name> <image-list-type> <task-order>
```

* \<user> is who should complete the task  
* \<list name> <list name> from above in (makeICLFromImageSetName.rb)  
* \<image-list-type> compare, OCTcompare, classify, classify_nine or quandrant.  
* \<task-order> is what precedence the image compare task takes relative to others assigned to this user.  


### Image-Classifier

#### Make Image Classify List
```bash
ruby makeImageClassifyList.rb <imageSet> <listName> <pctRepeat>
```

#### Add a task to a user:
```bash
ruby makeTask.rb <user> <image-list-name> <image-list-type> <task-order> [<description>]
```

### Grid-Classifier

#### Make Image Grid List
```bash
python3 makeGridList.py <imageSet> <listName>
```

#### Add a task to a user:
```bash
python3 makeTask.py <user> <image-list-name> <image-list-type> <task-order> [<description>]
```

### MIDRC-Challenge0

#### Make Challenge-0 List
```bash
python3 makeMIDRCChallenge0List.py <imageSet> <listName>
```

Ex:
```

```

#### Add a task to a user:
```bash
python3 makeTask.py <user> <image-list-name> <image-list-type> <task-order> [<description>]
```

Ex:
```

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

