#!/bin/bash
# Check if uwsgi service launch correctly  

MSG_OUTPUT="Scanning all uwsgi launched process: "

CONFIG_FILE=/srv/jormungandr/jormungandr.ini
URL_STATS="http://localhost:5050/_stats"

total_mem=0

NEED_PROCESS_LAUNCHED=$(cat $CONFIG_FILE |grep processes |awk  '{print $3 }')
COUNT_LAUNCHED_PROCESS=$(ps -U www-data aux|grep uwsgi |grep -v grep|grep -v $0|wc -l)

if [ $COUNT_LAUNCHED_PROCESS -gt $NEED_PROCESS_LAUNCHED ];then

	for pid in `curl -s $URL_STATS |grep "pid"`
	do
		get_pid=$(echo $pid |awk -F ':' '{print $2}'|sed 's/,//')	

		ps -p $get_pid -o comm= &>/dev/null
	
		if [ $? -ne 0 ];then
			MSG_OUTPUT="$MSG_OUTPUT PID $get_pid:[KO]"
			RISE_AN_ERROR=1

			# Quit loop
			break
		else
			MSG_OUTPUT="$MSG_OUTPUT PID $get_pid:[OK]"
			RISE_AN_ERROR=0

			# Get memory usage
			mem="$(ps --no-headers -p ${get_pid} -o rss)"
			total_mem="$(( ${total_mem} + ${mem} ))"
		fi
	done
else
	RISE_AN_ERROR=1
fi

if [ $RISE_AN_ERROR -eq 0 ];then
       echo "[Processus uwsgi] [$HOSTNAME] $MSG_OUTPUT | TOTAL=${total_mem}KB"
       exit 0
else
       echo "[Processus uwsgi] [$HOSTNAME] $MSG_OUTPUT | TOTAL=${total_mem}KB"
       exit 2
fi
