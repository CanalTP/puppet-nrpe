#!/bin/bash
# Script that's useful for checking if kibana started

GET_PID_BY_SYSTEMCTL=$(systemctl status kibana.service |grep "Main PID:"|awk '{print $3}')
GET_PID_BY_PS=$(ps aux|grep kibana|grep -v grep|grep -v $0|awk -F  " " '{print $2}')

 if [ ! -z $GET_PID_BY_SYSTEMCTL ] && [ ${GET_PID_BY_SYSTEMCTL} -eq ${GET_PID_BY_PS} ];then
  	echo "[$HOSTNAME] Kibana service is up"
	exit 0
 else
	echo "[$HOSTNAME] PID for Kibana service not match"
	exit 1
 fi
