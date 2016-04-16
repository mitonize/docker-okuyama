FROM alpine:3.3

MAINTAINER Mitsutaka WATANABE

# Install cURL
RUN apk --update add bash curl ca-certificates openjdk8-jre tar

#&& \
#            curl -Ls https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk > /tmp/glibc-2.21-r2.apk && \
#                apk add --allow-untrusted /tmp/glibc-2.21-r2.apk

ENV OKUYAMA_VERSION 0.9.6.3

ENV OKUYAMA_HOME /home/okuyama
# create user
RUN adduser -D okuyama

#
WORKDIR ${OKUYAMA_HOME}

# retreive sources of okuyama
RUN \
  echo downloading $OKUYAMA_VERSION.tar.gz \
  && curl -OL https://github.com/kobedigitallabo/okuyama/archive/$OKUYAMA_VERSION.tar.gz \
  && tar zxf $OKUYAMA_VERSION.tar.gz \
  && cp -a okuyama-$OKUYAMA_VERSION/install/* ${OKUYAMA_HOME} \
  && rm -rf okuyama-$OKUYAMA_VERSION $OKUYAMA_VERSION.tar.gz \
  && mkdir ${OKUYAMA_HOME}/logs \
  && chown -R okuyama:okuyama $OKUYAMA_HOME

#
USER okuyama
WORKDIR ${OKUYAMA_HOME}
COPY log4j.properties /home/okuyama/log4j.properties
COPY DataNode.properties /home/okuyama/conf/DataNode.properties
COPY docker-entrypoint.sh /entrypoint.sh

VOLUME ${OKUYAMA_HOME}/logs
VOLUME ${OKUYAMA_HOME}/keymapfile
EXPOSE 5553
EXPOSE 15553

ENTRYPOINT ["/entrypoint.sh"]

# About logs
# -v /var/log/okuyama:/home/okuyama/logs -v /host/okuyama/keymapfile:/home/okuyama/keymapfile
