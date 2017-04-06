FROM progrium/busybox

WORKDIR /home

RUN opkg-install curl bash ntpd ssl
RUN mkdir -p /var/spool/cron/crontabs

ARG TZ=UTC-8

ENV TZ ${TZ}

CMD export TZ=$TZ && ntpd -p pool.ntp.org && echo "$CRON_ENTRY" | crontab - && crond -f
