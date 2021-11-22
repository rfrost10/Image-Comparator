# Image-Comparator Dockerfile
FROM ubuntu

# These are essential
RUN apt update -y;
RUN apt install python3.8 -y;
RUN apt-get install python3-pip -y;
RUN apt-get install vim -y;

# to be deleted when ruby is faded out
RUN apt-get install ruby -y;
# to be deleted when ruby is faded out
RUN gem install couchrest;
# to be deleted when ruby is faded out
RUN gem install pry;

RUN apt-get install curl -y;

ENTRYPOINT ["bash"]