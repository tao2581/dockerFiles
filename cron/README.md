# docker_cron
This is lightweight cron schedule **1.2MB** that execute a single crontab entry

The crontab entry must be passed as CRON_ENTRY environment variable

Example
------------
This will print hello world every minute
`docker run -e "CRON_ENTRY=* * * * * echo hello world"  lodatol/cron`

This will invoke wp_cron every minute
`docker run -e "CRON_ENTRY=* * * * * wget -O /dev/null http://mysite/wp_cron"  lodatol/cron`
