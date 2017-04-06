FROM ubuntu:14.04

MAINTAINER tao2581 <tao2581@126.com>

ADD monitor.sh /home/monitor.sh

ADD monitor.conf /home/monitor.conf

RUN apt-get update && apt-get -y install curl

ENV DINTALK_TOKEN=null
ENV SITES=null
ENV CRON_ENTRY="*/3 * * * *"

# Clean up
USER root
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /home/

CMD bash -c ' echo "$SITES" > /home/monitor.conf && sed -i 's/DINTALK_TOKEN/'$DINTALK_TOKEN'/g' /home/monitor.sh &&  sed -i 's/DINTALK_TOKEN/'$DINTALK_TOKEN'/g' /home/monitor.sh && echo "$CRON_ENTRY bash /home/monitor.sh >> /var/log/cron.log 2>&1" | crontab - && cron -f && exec tail ---disable-inotify -F /var/log/cron.log'