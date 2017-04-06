FROM ubuntu:14.04

MAINTAINER tao2581 <tao2581@126.com>

ADD monitor.sh /home/monitor.sh

ADD monitor.conf /home/monitor.conf

RUN apt-get update && apt-get -y install curl

ARG DINTALK_TOKEN=null
ARG SITES=null
ARG CRON_ENTRY="*/3 * * * *"

ENV DINTALK_TOKEN=$DINTALK_TOKEN
ENV SITES=$SITES
ENV CRON_ENTRY=$CRON_ENTRY

RUN echo "$SITES" > /home/monitor.conf

RUN sed -i 's/DINTALK_TOKEN/'$DINTALK_TOKEN'/g' /home/monitor.sh && \
    sed -i 's/DINTALK_TOKEN/'$DINTALK_TOKEN'/g' /home/monitor.sh 

CMD echo "$CRON_ENTRY" | crontab - && crond -f