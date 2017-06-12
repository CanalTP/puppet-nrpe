#!/bin/bash
# Script that's useful for checking if influxdb started

GET_PID_BY_SYSTEMCTL=$(systemctl status influxdb.service |grep "Main PID:"|awk '{print $3}')
GET_PID_BY_PS=$(ps aux|grep influxdb|grep -v grep|grep -v $0|awk -F  " " '{print $2}')


 if [ ${GET_PID_BY_SYSTEMCTL} -eq ${GET_PID_BY_PS} ];then
  	echo "[$HOSTNAME] Infludb service is up"
	exit 0
 else
	echo "[$HOSTNAME] PID for Infludb service not match"
	exit 1
 fi
