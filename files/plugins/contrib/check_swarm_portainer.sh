#!/bin/bash
#Monitoring swarm portainer 
 
API_NAME="api"
MSG_OUTPUT="[CLUSTER] SWARM "
PORTAINER_RISE_AN_ERROR=0
DATE_TIME=$(date +%F_%T)

function check_portainer()
{ 
    logger "[$DATE_TIME] Checking if api portainer is up"
    GET_SRV_STARTED=$(docker -H localhost:2375 service ps api|grep "Running"|tail -1|awk '{print $4}')
   
    unset http_proxy 
    RET_CODE=$(curl -I $GET_SRV_STARTED:9000 -s -o /dev/null -w "%{http_code}") 
    
    if [ $RET_CODE -ne 200 ];then
	   PORTAINER_RISE_AN_ERROR=1
           MSG_OUTPUT="$MSG_OUTPUT api portainer is [DOWN]"	
    else
	   MSG_OUTPUT="$MSG_OUTPUT api portainer is [OK]"
    fi
}

#Call functions
check_portainer

 if [ $PORTAINER_RISE_AN_ERROR -eq 0 ];then
	echo "$MSG_OUTPUT"
  	exit 0 
 else
	echo "$MSG_OUTPUT"
	exit 2
 fi
