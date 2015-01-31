FROM centos:centos7

MAINTAINER Mitsutaka WATANABE 

RUN yum install java-1.7.0-openjdk-headless ant git -y -q

ENV OKUYAMA_HOME /home/okuyama
# create user
RUN adduser okuyama

# 
USER okuyama
WORKDIR ${OKUYAMA_HOME}

# retreive sources of okuyama
RUN git clone --depth 1 https://github.com/kobedigitallabo/okuyama.git okuyama-src

WORKDIR okuyama-src
RUN ant jar
RUN \
 cp -a ./install/* ${OKUYAMA_HOME}; \
 mkdir ${OKUYAMA_HOME}/logs

# Delete unnecessary files
USER root
RUN yum erase ant git -y && yum clean all

# 
USER okuyama
WORKDIR ${OKUYAMA_HOME}
RUN sed -i "s%/home/okuyama/okuyama/%/home/okuyama/%g" log4j.properties conf/DataNode.properties
COPY shell/okuyama ${OKUYAMA_HOME}/bin/

VOLUME ${OKUYAMA_HOME}/logs
#ENTRYPOINT 
CMD ["/home/okuyama/bin/okuyama", "/home/okuyama/conf/DataNode.properties", "start"]

EXPOSE 5553
EXPOSE 15553
# About logs
# -v /var/log/okuyama:/home/okuyama/logs -v /host/okuyama/keymapfile:/home/okuyama/keymapfile