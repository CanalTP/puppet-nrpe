#!/bin/bash
#Monitoring swarm microservice 
 
ENV_FLAG=$1
WIT_RISE_AN_ERROR=0

LIST_MICROSERVICE="wit"
MSG_OUTPUT="Scanning microservice report: "
MSG_NODE="Replicated node is OK"

DATE_TIME=$(date +%F_%T)

function check_parameters()
{
   logger "[$DATE_TIME] Checking if parameters are corrects"
   if [ $# -ne 1 ];then
  	 echo -e "\t \t [SWARM_MICROSERVICE] \033[31m Parameter is incorrect .. We expect 1 as [prd|rec|cus] \033[0m"
	 exit 1
   fi
}

function nb_start_service()
{
   GET_COUNT_SERVICE=$(docker -H localhost:2375 stack ps $LIST_MICROSERVICE | grep -ivE "remove|shutdown" | awk '{if (NR!=1) {print}}'| grep "Running" |awk '{print $5}'| wc -l) 
   if [ $GET_COUNT_SERVICE -ne 10 ]
   then
	MSG_NODE="Replicated node is KO"
   fi
}

function check_wit_service()
{
    logger "[$DATE_TIME] Checking if microservice is up"
    GET_SRV=$(docker -H localhost:2375 stack ps $LIST_MICROSERVICE | grep -ivE "remove|shutdown" | awk '{if (NR!=1) {print}}' | grep "Running"|awk '{print $4}'|sort|uniq)
    unset http_proxy 

    for srv in `echo $GET_SRV`
    do
	 RET_CODE=$(curl -I $srv:16000 -s -o /dev/null -w "%{http_code}")

	 if [ $RET_CODE -ne 200 ];then
                 WIT_RISE_AN_ERROR=1
                 MSG_OUTPUT="$MSG_OUTPUT $srv:[KO]"
         else 
                 MSG_OUTPUT="$MSG_OUTPUT $srv:[OK]"
         fi
    done
}

#Call functions
check_parameters $ENV_FLAG
nb_start_service
check_wit_service

 if [ $WIT_RISE_AN_ERROR -eq 0 ] && [ $GET_COUNT_SERVICE -eq 10 ];then
	echo "[WIT] [$MSG_NODE ${GET_COUNT_SERVICE}/10] $MSG_OUTPUT"
  	exit 0
 else
	echo "[WIT] [$MSG_NODE ${GET_COUNT_SERVICE}/10] $MSG_NODE $MSG_OUTPUT"
	exit 2
 fi
