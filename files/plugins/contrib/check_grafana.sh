#!/bin/bash
# Script that's useful for checking if grafana started

GET_PID_BY_SYSTEMCTL=$(systemctl status grafana-server.service |grep "Main PID:"|awk '{print $3}')
GET_PID_BY_PS=$(ps aux|grep grafana|grep -v grep|grep -v $0|awk -F  " " '{print $2}')


 if [ ${GET_PID_BY_SYSTEMCTL} -eq ${GET_PID_BY_PS} ];then
  	echo "[$HOSTNAME] Grafana service is up"
	exit 0
 else
	echo "[$HOSTNAME] PID for Grafana service not match"
	exit 1
 fi
