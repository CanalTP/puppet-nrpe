#!/bin/bash

#reccuperation des container en cours d'execution
list_docker=`docker ps --format '{{.Names}}'`

IFS=$'\n'
OUTPUT=""
PERFDATA="|"

#pour chaque 
for CONTAINER in $list_docker
do
	#echo $CONTAINER
	RUNNING=$(docker inspect --format="{{ .State.Running }}" $CONTAINER 2> /dev/null)
	GHOST=$(docker inspect --format="{{ .State.Dead }}" $CONTAINER)
	STARTED=$(docker inspect --format="{{ .State.StartedAt }}" $CONTAINER | cut -d "." -f1)
	NETWORK=$(docker inspect --format="{{ .NetworkSettings.IPAddress }}" $CONTAINER)
	
	STATS=$(docker stats --no-stream $CONTAINER | tail -1)
	CPU=$(echo $STATS | awk '{print $2}')
	MEMUSAGE=$(echo $STATS | awk '{print $6}')
	MEMUSED=$(echo $STATS | awk '{print $3$4}' | cut -d '/' -f1)
	NETIN=$(echo $STATS | awk '{print $9$10}' | cut -d '/' -f1)
	NETOUT=$(echo $STATS |  awk '{print $12$13}' | cut -d'/' -f2)
	CONTAINER=$(echo $CONTAINER |  cut -d. -f1)
	OUTPUT="$OUTPUT $CONTAINER is running. IP: $NETWORK, StartedAt: $STARTED\r\n"
	PERFDATA="$PERFDATA cpu-${CONTAINER}=$CPU mem-${CONTAINER}=$MEMUSED netIn-${CONTAINER}=$NETIN netOut-${CONTAINER}=$NETOUT"
done

echo -e "$OUTPUT $PERFDATA"
