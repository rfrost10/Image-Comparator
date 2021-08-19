# Image-Comaparator Dockerfile
FROM ubuntu
MAINTAINER bbearce <bbearce@mgh.harvard.edu>

# These are essential
RUN apt update -y;
RUN apt install -y python3.8
RUN apt-get install -y ruby
RUN apt-get install -y vim
RUN apt-get install -y curl

# CMD ["bash"]

ENTRYPOINT ["python3.8","-m", "http.server"]
CMD ["8080"]

