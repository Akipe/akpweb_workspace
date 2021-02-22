FROM ubuntu:20.04

MAINTAINER Akipe

WORKDIR /opt

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
        build-essential \
        npm \
        nodejs \
    && apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN /usr/bin/npm install -g gulp

RUN /usr/bin/npm install -g bower

VOLUME ["/opt"]
CMD ["gulp", "watch"]
