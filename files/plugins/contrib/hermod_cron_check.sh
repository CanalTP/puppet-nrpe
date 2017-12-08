#!/bin/bash
#Monitoring cron reporting
 
HERMOD_RISE_AN_ERROR=0
LOG_NAME="/var/log/reporting_hermod/report_$(date +%F)"
MSG_OUTPUT="Reporting mail returns"

function check_reporting_status()
{
    logger "Checking if reporting hermod correctly launched"
    COUNT=$(cat $LOG_NAME | grep -c "ERROR" )

	 if [ $COUNT -lt 1 ];then
                 HERMOD_RISE_AN_ERROR=1
                 MSG_OUTPUT="$MSG_OUTPUT status is OK"
         else 
                 MSG_OUTPUT="$MSG_OUTPUT status is KO"
         fi
}

check_reporting_status

 if [ $HERMOD_RISE_AN_ERROR -eq 0 ];then
	echo "$MSG_OUTPUT"
  	exit 0
 else
	echo "$MSG_OUTPUT"
	exit 2
 fi
