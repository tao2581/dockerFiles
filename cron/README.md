# docker_cron
This is lightweight cron schedule **1.2MB** that execute a single crontab entry

The crontab entry must be passed as CRON_ENTRY environment variable

## Environment variable
CRON_ENTRY
crontab setting files

TZ: timezone, such as : UTC-8

## Example
------------
- This will print hello world every minute
`docker run -e "CRON_ENTRY=* * * * * echo hello world"  lodatol/cron`

- This will invoke wp_cron every minute
`docker run -e "CRON_ENTRY=* * * * * wget -O /dev/null http://mysite/wp_cron"  lodatol/cron`

- Multiple task:  
```
CRON_ENTRY= 
35 11 * * * echo "should be executed at 11:35"
35 11 * * * echo "should be executed at 11:36"
* * * * * echo "should be executed every minute"
```

