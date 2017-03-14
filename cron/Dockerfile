FROM busybox

WORKDIR /home

ADD curl-7.30.0.ermine.tar.bz2 .

RUN mv /home/curl-7.30.0.ermine/curl.ermine /bin/curl \
    && rm -Rf /home/curl-7.30.0.ermine
    
RUN mkdir -p /var/spool/cron/crontabs

ARG TZ=UTC-8

ENV TZ ${TZ}

CMD export TZ=$TZ && ntpd -p pool.ntp.org && echo "$CRON_ENTRY" | crontab - && crond -f
