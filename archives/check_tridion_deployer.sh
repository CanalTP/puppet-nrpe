#!/bin/bash
# Script that's useful for checking if deployer url is ok  

ENV_VALUE=$(echo $HOSTNAME|cut -d "-" -f 2)

#checking arguments before url
if [ -z $ENV_VALUE ];then
	echo "[ERROR] Arguments expected"
	echo "[USAGE] $0 URL_TO_CHECK ENV $TYPE"
	exit 1
fi

URL="http://tridion-prd-deployer:a5fdbK3b7@10.93.39.83/HTTPUpload.aspx"
GET_CODE=$(curl  -s -o /dev/null -w "%{http_code}"  "$URL")

if [ $GET_CODE -eq 200 ];then
	echo "[OK] Check success for Tridion DEPLOYER [$ENV_VALUE]"
	exit 0
else
	echo "[KO] Check failed for Tridion DEPLOYER [$ENV_VALUE]"	
	exit 1 
fi
