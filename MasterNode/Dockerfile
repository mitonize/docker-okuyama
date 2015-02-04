FROM centos:centos7

MAINTAINER Mitsutaka WATANABE 

RUN yum install java-1.7.0-openjdk-headless -y

ENV OKUYAMA_VERSION 0.9.6.1

ENV OKUYAMA_HOME /home/okuyama
# create user
RUN adduser okuyama

# 
WORKDIR ${OKUYAMA_HOME}

# retreive sources of okuyama
RUN \
  yum install tar -y \
  && echo downloading $OKUYAMA_VERSION.tar.gz \
  && curl -OL https://github.com/kobedigitallabo/okuyama/archive/$OKUYAMA_VERSION.tar.gz \ 
  && tar zxf $OKUYAMA_VERSION.tar.gz \
  && cp -a okuyama-$OKUYAMA_VERSION/install/* ${OKUYAMA_HOME} \
  && rm -rf okuyama-$OKUYAMA_VERSION \
  && mkdir ${OKUYAMA_HOME}/logs \
  && chown -R okuyama:okuyama $OKUYAMA_HOME \
  && yum erase tar -y\
  && yum clean all

# 
USER okuyama
WORKDIR ${OKUYAMA_HOME}
COPY log4j.properties /home/okuyama/log4j.properties
COPY MasterNode.properties /home/okuyama/conf/MasterNode.properties
COPY docker-entrypoint.sh /entrypoint.sh

VOLUME ${OKUYAMA_HOME}/logs
EXPOSE 8888
EXPOSE 18888

ENTRYPOINT ["/entrypoint.sh"]

# About logs
# -v /var/log/okuyama:/home/okuyama/logs -v /host/okuyama/keymapfile:/home/okuyama/keymapfile
