#!/bin/bash
#Monitoring swarm microservice 
 
ENV_FLAG=$1
LOG_RISE_AN_ERROR=0
PROBE_RISE_AN_ERROR=0
LOCALITER_RISE_AN_ERROR=0
UPLOAD_RISE_AN_ERROR=0
OAUTH2_RISE_AN_ERROR=0

LIST_MICROSERVICE="log-ms probe-ms shiva_shiva shiva_app-event  oauth2-ms"
MSG_OUTPUT="Scanning microservice report: "
COMPLETE_NAME=$(echo $ENV_FLAG |tr '[A-Z]' '[a-z]')
DATE_TIME=$(date +%F_%T)

function check_parameters()
{
   logger "[$DATE_TIME] Checking if parameters are corrects"
   if [ $# -ne 1 ];then
  	 echo -e "\t \t [SWARM_MICROSERVICE] \033[31m Parameter is incorrect .. We expect 1 as [prod|rec|cus] \033[0m"
	 exit 1
   fi
}

function check_log_ms()
{ 
    logger "[$DATE_TIME] Checking if microservice log-ms is up"
    GET_SRV_STARTED=$(docker -H localhost:2375 service ps ter-$COMPLETE_NAME-log-ms|grep "Running"|tail -1|awk '{print $4}')
   
    unset http_proxy 
    RET_CODE=$(curl -I $GET_SRV_STARTED:3603 -s -o /dev/null -w "%{http_code}") 
    
    if [ $RET_CODE -ne 200 ];then
	   LOG_RISE_AN_ERROR=1
           MSG_OUTPUT="$MSG_OUTPUT Log-ms:[KO]"	
    else
	   MSG_OUTPUT="$MSG_OUTPUT Log-ms:[OK]"
    fi
}

function check_probe_ms()
{   
    logger "[$DATE_TIME] Checking if microservice probe-ms is up"
    GET_SRV_STARTED=$(docker -H localhost:2375 service ps ter-$COMPLETE_NAME-probe-ms|grep "Running"|tail -1|awk '{print $4}')
    
    unset http_proxy 
    RET_CODE=$(curl -I $GET_SRV_STARTED:3602 -s -o /dev/null -w "%{http_code}")
    
    if [ $RET_CODE -ne 200 ];then
           PROBE_RISE_AN_ERROR=1
           MSG_OUTPUT="$MSG_OUTPUT Probe-ms:[KO]"
    else
           MSG_OUTPUT="$MSG_OUTPUT Probe-ms:[OK]"
    fi
}

function check_shiva()
{
    logger "[$DATE_TIME] Checking if microservice shiva is up"
    GET_SRV_STARTED=$(docker -H localhost:2375 service ps shiva_shiva |grep "Running"|tail -1|awk '{print $4}')

    unset http_proxy 
    RET_CODE=$(curl -I $GET_SRV_STARTED:3003 -s -o /dev/null -w "%{http_code}")

    if [ $RET_CODE -ne 200 ] && [ $RET_CODE -ne 302 ];then
           SHIVA_RISE_AN_ERROR=1
           MSG_OUTPUT="$MSG_OUTPUT Shiva:[KO]"
    else
           MSG_OUTPUT="$MSG_OUTPUT Shiva:[OK]"
    fi
}

function check_shiva-app-event()
{
    logger "[$DATE_TIME] Checking if microservice shiva-app-event is up"
    GET_SRV_STARTED=$(docker -H localhost:2375 service ps shiva-app-event_shiva-app-event |grep "Running"|tail -1|awk '{print $4}')

    unset http_proxy
    l_TELNET=`echo "quit" | telnet $GET_SRV_STARTED 3004 | grep "Escape character is"` 
    
    if [ "$?" -ne 0 ]; then
    # if [ $RET_CODE -ne 200 ] && [ $RET_CODE -ne 302 ];then
           SHIVA_APP_EVENT_RISE_AN_ERROR=1
           MSG_OUTPUT="$MSG_OUTPUT Shiva-app-event:[KO]"
    else
           SHIVA_APP_EVENT_RISE_AN_ERROR=0
           MSG_OUTPUT="$MSG_OUTPUT Shiva-app-event:[OK]"
    fi
}

function check_upload()
{
    logger "[$DATE_TIME] Checking if microservice upload is up"
    GET_SRV_STARTED=$(docker -H localhost:2375 service ps ter-$COMPLETE_NAME-upload-ms|grep "Running"|tail -1|awk '{print $4}')

    unset http_proxy 
    RET_CODE=$(curl -I $GET_SRV_STARTED:3001/getConfig -s -o /dev/null -w "%{http_code}")

    if [ $RET_CODE -ne 200 ];then
           UPLOAD_RISE_AN_ERROR=1
           MSG_OUTPUT="$MSG_OUTPUT Upload-ms:[KO]"
    else
           MSG_OUTPUT="$MSG_OUTPUT Upload-ms:[OK]"
    fi
}

function check_oauth()
{
    logger "[$DATE_TIME] Checking if microservice oauth2 is up"
    GET_SRV_STARTED=$(docker -H localhost:2375 service ps ter-$COMPLETE_NAME-oauth2-ms|grep "Running"|tail -1|awk '{print $4}')

    unset http_proxy 
    RET_CODE=$(curl -I $GET_SRV_STARTED:43000 -s -o /dev/null -w "%{http_code}")

    if [ $RET_CODE -ne 200 ];then
           UPLOAD_RISE_AN_ERROR=1
           MSG_OUTPUT="$MSG_OUTPUT Oauth2-ms:[KO]"
    else
           MSG_OUTPUT="$MSG_OUTPUT Oauth2-ms:[OK]"
    fi
}

#Call functions
check_parameters $ENV_FLAG
check_probe_ms
check_shiva
check_shiva-app-event
check_oauth

 if [ $PROBE_RISE_AN_ERROR -eq 0 ] && [ $SHIVA_RISE_AN_ERROR -eq 0 ] && [ $SHIVA_APP_EVENT_RISE_AN_ERROR -eq 0 ] && [ $OAUTH2_RISE_AN_ERROR -eq 0 ];then
	echo "[CLUSTER_SWARM] [MICROSERVICE] $MSG_OUTPUT"
  	exit 0
 else
	echo "[CLUSTER_SWARM] [MICROSERVICE] $MSG_OUTPUT"
	exit 2
 fi
