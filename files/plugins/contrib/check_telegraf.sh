#!/bin/bash
# Script that's useful for checking if telegraf started

GET_PID_BY_SYSTEMCTL=$(systemctl status telegraf|grep "Main PID:"|awk '{print $3}')
GET_PID_BY_PS=$(ps aux|grep telegraf|grep -v grep|grep -v $0|awk -F  " " '{print $2}')


 if [ ! -z $GET_PID_BY_SYSTEMCTL ] && [ ${GET_PID_BY_SYSTEMCTL} -eq ${GET_PID_BY_PS} ];then
  	echo "[$HOSTNAME] Telegraf service is up"
	exit 0
 else
	echo "[$HOSTNAME] PID for Telegraf service not match"
	exit 1
 fi
