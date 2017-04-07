#!/bin/bash
echo "$SITES" > /home/monitor.conf
sed -i 's/DINTALK_TOKEN/'$DINTALK_TOKEN'/g' /home/monitor.sh 
echo "$CRON_ENTRY bash /home/monitor.sh >> /var/log/cron.log 2>&1" | crontab - 
cron -f 
exec tail ---disable-inotify -F /var/log/cron.log