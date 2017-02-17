#!/bin/bash
#Monitoring swarm heath by quering manager nodes and rise an alerte when problems occured
#Launch in manager swarm only
 
HOST_SOCKET=$1
PORT_SOCKET=$2
ENV_VALUE=$3

RISE_ERROR=0
MSG_OUTPUT="Everything is ok in swarm"
DATE_TIME=$(date +%F_%T)

function check_parameters()
{
   logger "[$DATE_TIME] Checking if parameters are corrects"
   if [ $# -ne 3 ];then
  	 echo -e "\t \t [SWARM_CLUSTER] \033[31m Parameters are incorrect .. We expect 3 as [IP or DNS] [SOCKET_TCP_BIND] [ENV] \033[0m"
	 exit 1
   fi
}

function get_manager_names()
{
    logger "[$DATE_TIME] Getting list manager node from master node"
    GET_LEADER_MANAGER=$(docker -H $HOST_SOCKET:$PORT_SOCKET node ls|grep -E "Leader" |sed 's#*##'  |awk '{print $2}')
    GET_OTHER_MANAGER=$(docker -H $HOST_SOCKET:$PORT_SOCKET node ls|grep -E "Reachable"|sed 's#*##' |awk  '{print $2}')
    GET_BROKEN_NODE=$(docker -H $HOST_SOCKET:$PORT_SOCKET node ls|grep -E "Unreachable"|sed 's#*##' |awk  '{print $2}')
}

function get_node_unreachability()
{
   logger "[$DATE_TIME] Getting broken node if exist"
   for srv in $(echo $GET_BROKEN_NODE)
   do
	if [ ! -z ${GET_BROKEN_NODE} ];then
   		RISE_ERROR=1
		MSG_OUTPUT="Node $srv is unreachable"
	else
		echo "debug"
	fi
   done
}

function get_leader_reachability()
{
    logger "[$DATE_TIME] Checking manager leader status"
    GET_STATUS=$(docker -H $HOST_SOCKET:$PORT_SOCKET node inspect $GET_LEADER_MANAGER --format "{{ .ManagerStatus.Reachability }}")

    if [ $GET_STATUS != "reachable" ];then
	    RISE_ERROR=1
	    MSG_OUTPUT="Manager $GET_LEADER_MANAGER is broken"
	    echo "[$HOSTNAME][$ENV_VALUE][SWARM_CLUSTER] Manager $GET_LEADER_MANAGER have some trouble"
    else 
	    echo "[$HOSTNAME][$ENV_VALUE][SWARM_CLUSTER] Manager $GET_LEADER_MANAGER is OK"
    fi
}

function get_manager_reachability()
{ 
  for e in $(echo $GET_OTHER_MANAGER)
  do
   	  logger "[$DATE_TIME] Checking other manager status"
	  GET_STATUS=$(docker -H $HOST_SOCKET:$PORT_SOCKET node inspect $e --format "{{ .ManagerStatus.Reachability }}")

	  if [ $GET_STATUS != "reachable" ];then
               RISE_ERROR=1
	       echo "[$HOSTNAME][$ENV_VALUE][SWARM_CLUSTER] Manager $e have some trouble"
	       MSG_OUTPUT="Manager $e is broken"
          else
               echo "[$HOSTNAME][$ENV_VALUE][SWARM_CLUSTER] Manager $e is OK"
          fi
  done
}


#Call functions
check_parameters $HOST_SOCKET $PORT_SOCKET $ENV_VALUE
get_manager_names
get_node_unreachability
get_leader_reachability
get_manager_reachability

if [ $RISE_ERROR -eq 1 ];then
	echo "[$ENV_VALUE][SWARM_CLUSTER][KO] $MSG_OUTPUT"
  	exit 1
else
	echo "[$ENV_VALUE] [SWARM_CLUSTER][OK] $MSG_OUTPUT"
	exit 0
fi
