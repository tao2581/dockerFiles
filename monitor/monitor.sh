#!/bin/bash
currentTime=`date '+%m月%d日%H时%M分'`
currentTimeStamp=`date '+%s'` 
basepath=$(cd `dirname $0`; pwd)
if [ ! -d "/var/tmp/webMonitor" ]; then
    mkdir -p "/var/tmp/webMonitor"
fi
sendFailMessage()
{
    curl 'https://oapi.dingtalk.com/robot/send?access_token=DINTALK_TOKEN' \
      -H 'Content-Type: application/json' \
      -d '
      {"msgtype": "markdown", 
        "markdown": {
          "title": "服务器宕机通知",
          "text": "'$1'\n## 服务器宕机通知，以下网站存在故障\n\n'$2'"
        }
      }' > /dev/null
}

sendRecoverMessage()
{
    curl 'https://oapi.dingtalk.com/robot/send?access_token=DINTALK_TOKEN' \
      -H 'Content-Type: application/json' \
      -d '
      {"msgtype": "markdown", 
        "markdown": {
          "title": "服务器恢复通知",
          "text": "'$1'\n## 服务器恢复通知，以下网站已恢复访问\n\n'$2'"
        }
      }' > /dev/null
}

failMessage=""
recoverMessage=""
for line in `cat $basepath/monitor.conf`
do
    lastTime=$currentTimeStamp
    if [ -f "$fileName" ]; then
        lastTime=`cat $fileName`
    fi

    fileName="/var/tmp/webMonitor/"`echo $line | base64`
    httpCode=`curl -s -m 3 -o /dev/null -w %{http_code} $line`
    if [ $httpCode == 200 ] || [ $httpCode == 301 ] || [ $httpCode == 302 ]; then
    #if [ `curl -s -m 3 -o /dev/null -w %{http_code} $line | grep '200\|301\|302'` ];then
        # 如果有失败通知
        if [ -f "$fileName" ]; then
            rm -f  "$fileName"
            recoverMessage="${recoverMessage}\n\n[${line}](${line})--*已恢复访问*"
        fi
    else        
        # 不存在历史通知或已间隔15分钟 发送通知
        if [ ! -f "$fileName" ] || [  $[currentTimeStamp - lastTime ] -gt $[60*15] ]; then
            failMessage="${failMessage}\n\n[${line}](${line})--*无法访问[${httpCode}]*"
            echo "$currentTimeStamp" > $fileName
        fi       
    fi
done
if [ "$failMessage" != ""  ]; then
  echo $currentTime" 宕机：["$failMessage"] "
    sendFailMessage $currentTime $failMessage
fi

if [ "$recoverMessage" != ""  ]; then
  echo $currentTime" 恢复: ["$recoverMessage"]"
    sendRecoverMessage $currentTime $recoverMessage
fi