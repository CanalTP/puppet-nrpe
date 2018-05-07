#!/bin/bash
#Monitoring swarm microservice 
 
ENV_FLAG=$1
LOG_RISE_AN_ERROR=0
PROBE_RISE_AN_ERROR=0
GORMUNGANDR_RISE_AN_ERROR=0
TRAEFIK_RISE_AN_ERROR=0

LIST_MICROSERVICE="traefik gormungandr"
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

function check_traefik()
{
    logger "[$DATE_TIME] Checking if microservice traefik is up"
    GET_SRV_STARTED=$(docker -H localhost:2375 service ps traefik_traefik |grep "Running")

    if [ -z "$GET_SRV_STARTED" ];then
           TRAEFIK_RISE_AN_ERROR=1
           MSG_OUTPUT="$MSG_OUTPUT Traefik:[KO]"
    else
           MSG_OUTPUT="$MSG_OUTPUT Traefik:[OK]"
    fi
}

function check_gormungandr()
{
    logger "[$DATE_TIME] Checking if microservice gormundanr is up"
    GET_SRV_STARTED=$(docker -H localhost:2375 service ps gormungandr_schedules |grep "Running")

    if [ -z "$GET_SRV_STARTED" ];then
           GORMUNGANDR_RISE_AN_ERROR=1
           MSG_OUTPUT="$MSG_OUTPUT Gormungandr:[KO]"
    else
           MSG_OUTPUT="$MSG_OUTPUT Gormungandr:[OK]"
    fi
}

#Call functions
check_parameters $ENV_FLAG
check_gormungandr
check_traefik

 if [ $GORMUNGANDR_RISE_AN_ERROR -eq 0 ] && [ $TRAEFIK_RISE_AN_ERROR -eq 0 ];then
	echo "[CLUSTER_SWARM] [MICROSERVICE] $MSG_OUTPUT"
  	exit 0
 else
	echo "[CLUSTER_SWARM] [MICROSERVICE] $MSG_OUTPUT"
	exit 2
 fi
