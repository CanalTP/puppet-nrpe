#!/bin/bash
#Monitoring swarm microservice 
 
ENV_FLAG=$1
HERMOD_RISE_AN_ERROR=0
TOKEN="Authorization: 82f31b97-7cfa-4b22-9380-13046b918a7f"
URL_TO_CHECK="https://hermod-production.canaltp.fr/v1/status"

STACK_NAME="hermod"
MSG_OUTPUT=""
MSG_NODE="Replicated node is OK"

DATE_TIME=$(date +%F_%T)

function check_parameters()
{
   logger "[$DATE_TIME] Checking if parameters are corrects"
   if [ $# -ne 1 ];then
  	 echo -e "\t \t [HERMOD] \033[31m Parameter is incorrect .. We expect 1 as [prod] \033[0m"
	 exit 1
   fi
}

function nb_start_service()
{
   GET_COUNT_SERVICE=$(docker -H localhost:2375 stack ls |grep $STACK_NAME |awk '{ print $2 }') 
   if [ $GET_COUNT_SERVICE -ne 2 ]
   then
	MSG_NODE="Hermod stack don't content 2 services .. Please check"
   fi
}

function check_hermod_service()
{
    logger "[$DATE_TIME] Checking if api hermod responding"
    unset http_proxy 
    
    curl -s -H "$TOKEN" $URL_TO_CHECK | grep "OK" 
    RET_CODE=$?

	 if [ $RET_CODE -eq 0 ];then
                 MSG_OUTPUT="$MSG_OUTPUT and veryfing url status is OK"
         else 
                 HERMOD_RISE_AN_ERROR=1
                 MSG_OUTPUT="$MSG_OUTPUT and veryfing url status is KO"
         fi
}

#Call functions
check_parameters $ENV_FLAG
nb_start_service
check_hermod_service

 if [ $HERMOD_RISE_AN_ERROR -eq 0 ] && [ $GET_COUNT_SERVICE -eq 2 ];then
	echo "[HERMOD] [$MSG_NODE ${GET_COUNT_SERVICE}/2] $MSG_OUTPUT"
  	exit 0
 else
	echo "[HERMOD] [$MSG_NODE ${GET_COUNT_SERVICE}/2] $MSG_OUTPUT"
	exit 2
 fi
