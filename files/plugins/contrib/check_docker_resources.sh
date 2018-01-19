#!/bin/bash

#reccuperation des container en cours d'execution
list_docker=`docker ps --format '{{.Names}}'`

IFS=$'\n'
OUTPUT=""
PERFDATA="|"

docker stats --no-stream --all --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" > /tmp/docker-ressources.txt

#pour chaque 
for CONTAINER in $list_docker
do
	docker inspect $CONTAINER > /tmp/$CONTAINER-inpect.txt	
	RUNNING=`grep -r "Running" /tmp/$CONTAINER-inpect.txt | awk '{print $2}' | sed -e s/,//g` 
	CPU=`grep $CONTAINER /tmp/docker-ressources.txt | awk '{print $2}'`
	MEMORY_USAGE_INFOS=`grep $CONTAINER /tmp/docker-ressources.txt | awk '{print $4}'| sed -e s/GiB/GB/ | sed -e s/MiB/MB/`
	MEMORY_LIMIT_INFOS=`grep $CONTAINER /tmp/docker-ressources.txt | awk '{print $7}'| sed -e s/GiB/GB/ | sed -e s/MiB/MB/`
	MEMORY_USAGE="`grep $CONTAINER /tmp/docker-ressources.txt | awk '{print $3}'`$MEMORY_USAGE_INFOS"
	MEMORY_LIMIT="`grep $CONTAINER /tmp/docker-ressources.txt | awk '{print $6}'`$MEMORY_LIMIT_INFOS"
		
	CONTAINER_NAME=`echo $CONTAINER | awk -F '.' '{print $1}'`
	PERFDATA="$PERFDATA cpu-$CONTAINER_NAME=$CPU mem_usage-$CONTAINER_NAME=$MEMORY_USAGE mem_limit-$CONTAINER_NAME=$MEMORY_LIMIT" 
	
	
	#echo "CPU USAGE=$CPU" 
done

echo -e "PERF $PERFDATA"
