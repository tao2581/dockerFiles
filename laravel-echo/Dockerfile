FROM phusion/baseimage:latest

MAINTAINER Matt Alford <malford@nsgdv.com>

RUN mkdir -p /var/script

RUN apt-get update && apt-get install -y nodejs
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN apt-get install -y npm

# Upgrade node and npm to latest version
RUN     npm cache clean
RUN     npm install -g n
RUN     n stable
RUN     curl -L https://npmjs.org/install.sh | sh

RUN /usr/bin/npm install express && /usr/bin/npm install socket.io && /usr/bin/npm install redis && /usr/bin/npm install ioredis && /usr/bin/npm install redis-notifier && /usr/bin/npm install request && /usr/bin/npm install node-pre-gyp && /usr/bin/npm install sqlite3 && /usr/bin/npm install -g laravel-echo-server 

WORKDIR /var/www/Api/

RUN usermod -u 1000 www-data

EXPOSE 6001/tcp

CMD ["laravel-echo-server", "start"]
