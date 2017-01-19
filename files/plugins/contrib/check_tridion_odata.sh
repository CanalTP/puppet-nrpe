#!/bin/bash
# Script that's useful for checking if odata url is ok for env

ENV_VALUE=$(echo $HOSTNAME|cut -d "-" -f 2)

#checking arguments before url
if [ -z $ENV_VALUE ];then
	echo "[ERROR] Arguments expected"
	echo "[USAGE] $0 URL_TO_CHECK ENV $TYPE"
	exit 1
fi

URL=$(echo $HOSTNAME:8080/cd_webservice/odata.svc/Publications)
GET_CODE=$(curl  -s -o /dev/null -w "%{http_code}"  "http://$URL")

if [ $GET_CODE -eq 200 ];then
	echo "[OK] Check success for Tridion ODATA [$ENV_VALUE]"
	exit 0
else
	echo "[KO] Check failed for Tridion ODATA [$ENV_VALUE]"	
	exit 1 
fi

