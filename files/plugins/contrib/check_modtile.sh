#!/bin/bash
# Script that's useful for checking if modtile is up

URL=http://${HOSTNAME}:8080/mod_tiles
RESULT=/tmp/result.out

unset http_proxy 
RET_CODE=$(curl $URL -s -o $RESULT -w "%{http_code}")

 if [ $RET_CODE -eq 200 ];then
	 NoResp200=$(cat $RESULT |grep "NoResp200"|awk -F ":" '{print $2}'|tr -d [:blank:])
	 NoResp304=$(cat $RESULT |grep "NoResp304"|awk -F ":" '{print $2}'|tr -d [:blank:])
	 NoResp404=$(cat $RESULT |grep "NoResp404"|awk -F ":" '{print $2}'|tr -d [:blank:])
	 NoResp503=$(cat $RESULT |grep "NoResp503"|awk -F ":" '{print $2}'|tr -d [:blank:])
	 NoFreshCache=$(cat $RESULT |grep "NoFreshCache"|awk -F ":" '{print $2}'|tr -d [:blank:])
	 NoOldCache=$(cat $RESULT |grep "NoOldCache"|awk -F ":" '{print $2}'|tr -d [:blank:])
	 NoVeryOldCache=$(cat $RESULT |grep "NoVeryOldCache"|awk -F ":" '{print $2}'|tr -d [:blank:])
	 NoFreshRender=$(cat $RESULT |grep "NoFreshRender"|awk -F ":" '{print $2}'|tr -d [:blank:])
	 NoOldRender=$(cat $RESULT |grep "NoOldRender"|awk -F ":" '{print $2}'|tr -d [:blank:])
	 NoTileBufferReads=$(cat $RESULT |grep "NoTileBufferReads"|awk -F ":" '{print $2}'|tr -d [:blank:])
	 DurationTileBufferReads=$(cat $RESULT |grep "DurationTileBufferReads"|awk -F ":" '{print $2}'|tr -d [:blank:])
	 NoRes200Layer=$(cat $RESULT |grep "NoRes200Layer"|awk -F ":" '{print $2}'|tr -d [:blank:])
	 NoRes404Layer=$(cat $RESULT |grep "NoRes404Layer"|awk -F ":" '{print $2}'|tr -d [:blank:])
	 echo "Metriques modtile: NoResp200=$NoResp200| NoResp304=$NoResp304| NoResp404:$NoResp404| NoResp503=$NoResp503| NoFreshCache=$NoFreshCache| NoOldCache=$NoOldCache| NoVeryOldCache=$NoVeryOldCache| NoFreshRender=$NoFreshRender| NoOldRender=$NoOldRender| NoTileBufferReads=$NoTileBufferReads| DurationTileBufferReads=$DurationTileBufferReads| NoRes200Layer=$NoRes200Layer| NoRes404Layer=$NoRes404Layer" 
	 echo "[$HOSTNAME] Modtile is OK"
         exit 0
 else
	echo "[$HOSTNAME] Modtile failed return"
	exit 1

 fi
