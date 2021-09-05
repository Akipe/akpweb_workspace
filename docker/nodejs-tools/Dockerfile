FROM node:16.8

ENV NODE_ENV=production

MAINTAINER Akipe

WORKDIR /opt

RUN npm install --production -g gulp

RUN npm install --production -g bower

VOLUME ["/opt"]
CMD ["gulp", "watch"]
