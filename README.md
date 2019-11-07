# Image Classifier and Comparator

Purpose: Set up a static webpage and server to host classifier/pairwise comparator tasks for images 

I am not the original author of these files. This repository contains aggregated and updated files from previous developers. See acknowledgements below.

## Instructions for setup
1. Set up AWS instance. A free tier server is adequate for small scale deployment. I also recommend setting up an SFTP client such as FileZilla for easier file transfer (will require your public IPv4/DNS and a security key .pem file)
2. SSH to your server using your custom command/security key provided by AWS. Move dockerfile to the root directory of your AWS server 
3. Create docker image using instructions described here: https://github.com/CollinWen/Image-Comparator-Dockerfile
4. Of note, the above repository's dockerfile works, but does not work completely, and some of the webpage code did not work. I have attached my proposed fixes in my dockerfile but have not been able to verify if it works. If the dockerfile above does not work for you, I would recommend replacing the above repository's files with this repository's files and using sed to replace all of my IP addrresses with your server's.
5. Deploy server using the following:

```bash
python -m SimpleHTTPServer 8080
```
6. Use tmux to before deploying the server to allow the server to run indefinitely

## Instructions for use
1. To create and setup the database, run the following (use the <db_name> you used from the docker build command):  

```bash
$ curl -X PUT http://admin:<password>@localhost:5984/<db_name>
$ cd /Image-Comparator/dbutil
$ curl -X PUT http://admin:<password>@localhost:5984/<db_name>/_design/basic_views -d @basic_views.json
```

2. Add Images to DB:

```bash
$ ruby addImagesToDb_jkc.rb <imageFolder> <imageSetName>
```

* <imageFolder> is ```/data``` inside the docker, which was mounted during container creation.  
* <imageSetName> is the name for the image set.  

> \<imageFolder> can be any folder if not using docker.


3. Add images to an Image Compare List:

```bash
$ makeICLFromImageSetName.rb <image set name> <pct repeat> <list name>
```
* \<image set name> was the name given to addImagesToDb_jkc.rb  
* \<pct repeat> is the percentage of repeated pairs to be displayed  
* \<list name> is a new list name  

4. Add a task to a user:

```bash
$ makeTask.rb <user> <image-list name> <image-list-type> <task-order>
```
* \<user> is who should complete the task  
* \<image-list name> this is <list name> from above in (makeICLFromImageSetName.rb)  
* \<image-list-type> ```compare``` or ```OCTcompare```.  
* \<task-order> is what precedence the image compare task takes relative to others assigned to this user.   

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
