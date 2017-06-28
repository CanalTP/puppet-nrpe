#!/bin/bash

# If you want to injure or insult the author, talk to Fabien Degomme <fabien.degomme@kisio.org>
# 
# This script is related to issue DEVOP-1566 and works only with Bash !


file_loc=/srv/www/cms2.infolignes.fr/shared/logs/synchronizeIncidentsWithDB_$(date +%Y%m%d).log
number_of_last_executions=5

last_executions_status=$(grep -n "Etat d'exécution" "${file_loc}" | tail -$number_of_last_executions)

failed_executions=0
success_executions=0

for execution_status in ${last_executions_status}
do
	if echo "${execution_status}" | grep -q "réussi"
	then
		let "success_executions++"
	elif echo "${execution_status}" | grep -q "échoué"
	then
		let "failed_executions++"
	fi
done

if [ $failed_executions -ne $number_of_last_executions ]
then
	echo "OK: ${failed_executions} failed executions over ${number_of_last_executions} last, no worry"
	exit 0
elif [ $failed_executions -eq $number_of_last_executions ]
then
	echo "CRITICAL: ${failed_executions} failed executions over ${number_of_last_executions} last in ${file_loc}, you must reload apache !"
	exit 2
else
	echo "UNKNOWN: unknown error, it should not happen ! Sorry but you must watch yourself what's wrong"
	exit 3
fi

