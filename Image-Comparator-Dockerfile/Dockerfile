# Image-Comaparator Dockerfile
FROM ubuntu
MAINTAINER Jimmy Chen <chenjim@ohsu.edu>

# arguments
# ARG db_name="myrop"
# ARG host_local_ip="ec2-13-58-138-74.us-east-2.compute.amazonaws.com"

# install required packages
# Calling these packages out as extra for now...I'm about to find out :)
#RUN apt-get install -y nginx 
#RUN apt-get install -y build-essential
#RUN apt-get install -y nodejs
#RUN apt-get install -y apache2

# These are essential
RUN apt-get install -y git
RUN apt-get install -y python
RUN apt-get install -y ruby
RUN apt-get install -y vim
RUN apt-get install -y curl

# clone repository
RUN cd /



### BB 10/31/2019 ###

#RUN git clone https://github.com/CollinWen/Image-Comparator.git
RUN git clone https://github.com/jche253/Fundus_Classifier_Comparator.git
RUN mv Fundus_Classifier_Comparator/Image-Comparator ./
RUN mv Fundus_Classifier_Comparator/README.md ./
RUN rm -r Fundus_Classifier_Comparator

### BB 10/31/2019 ###


# replace all instances of "rop_images" and "172.16.42.15" with new database name and new ip address

#From Collin Wen's repo, the following doesn't work
#RUN cd /Image-Comparator/
#RUN grep -rl "rop_images" /Image-Comparator/* | xargs sed -i 's/ret_images/myrop/g'
#RUN grep -rl "172.16.42.15" /Image-Comparator/* | xargs sed -i 's/ec2-18-220-36-255.us-east-2.compute.amazonaws.com/ec2-13-58-138-74.us-east-2.compute.amazonaws.com/g'
#RUN grep -rl "5984" /Image-Comparator/* | xargs sed -i 's/5984/<database_port>/g'

#Would recommend using the following instead: 
#RUN grep -rl 'myrop' Image-Comparator/ | xargs sed -i 's/myrop/ret_images/g'
#RUN grep -rl '18.221.228.73' Image-Comparator/ | xargs sed -i 's/18.221.228.73/18.234.167.89/g'
#RUN grep -rl '5984' Image-Comparator/ | xargs sed -i 's/5984/5984/g'





### BB 10/31/2019 ###

RUN grep -rl 'ec2-54-152-40-100.compute-1.amazonaws.com' /Image-Comparator/ | xargs sed -i 's/ec2-54-152-40-100.compute-1.amazonaws.com/ec2-18-234-167-89.compute-1.amazonaws.com/g'
RUN grep -rl 'ec2-34-201-70-163.compute-1.amazonaws.com' /Image-Comparator/ | xargs sed -i 's/ec2-34-201-70-163.compute-1.amazonaws.com/ec2-18-234-167-89.compute-1.amazonaws.com/g'
RUN grep -rl 'ec2-18-220-36-255.us-east-2.compute.amazonaws.com' /Image-Comparator/ | xargs sed -i 's/ec2-18-220-36-255.us-east-2.compute.amazonaws.com/ec2-18-234-167-89.compute-1.amazonaws.com/g'

RUN grep -rl '54956' /Image-Comparator/ | xargs sed -i 's/54956/5984/g'




### BB 10/31/2019 ###





# install couchdb
# RUN export DEBIAN_FRONTEND=noninteractive
# RUN echo "deb http://apache.bintray.com/couchdb-deb bionic main" \ | tee -a /etc/apt/sources.list
# RUN curl -L https://couchdb.apache.org/repo/bintray-pubkey.asc \ | apt-key add -
# RUN apt-get update && apt-get install -yq couchdb

# configure couchdb
# 1
# 0.0.0.0
# password
# password

# start couchdb
# RUN service couchdb start
# RUN curl -X PUT http://admin:password@127.0.0.1:5984/_users
# RUN curl -X PUT http://admin:password@127.0.0.1:5984/_replicator

# Create database, add documents
# RUN curl -X PUT http://admin:password@localhost:5984/$db_name
# RUN cd Image-Comparator/dbutil
# RUN curl -X PUT http://admin:password@localhost:5984/$db_name/_design/basic_views -d @basic_views.json

CMD ["echo","Image created"]
