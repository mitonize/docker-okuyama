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
RUN sed -i "s%/home/okuyama/okuyama/%/home/okuyama/%g" log4j.properties
COPY DataNode.properties /home/okuyama/conf/DataNode.properties
COPY docker-entrypoint.sh /entrypoint.sh

VOLUME ${OKUYAMA_HOME}/logs
VOLUME ${OKUYAMA_HOME}/keymapfile
EXPOSE 5553
EXPOSE 15553

ENTRYPOINT ["/entrypoint.sh"]

# About logs
# -v /var/log/okuyama:/home/okuyama/logs -v /host/okuyama/keymapfile:/home/okuyama/keymapfile
