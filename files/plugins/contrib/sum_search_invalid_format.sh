#!/bin/bash 
# Check on sum app log the flag invalid format 

LOG_DIR=/var/lib/tomcat7-sum/logs/sum-server2
FILENAME=SumServer.log
PID_FILE=/tmp/sum_search_invalid_format.pid
FLAG_TO_SEARCH="java.lang.IllegalArgumentException: Invalid format: | is malformed at"

function clean_process
{
   rm -f $PID_FILE
}

if [ ! -f $PID_FILE ];then
 	touch $PID_FILE
	

	ERROR_COUNT=$(cat $LOG_DIR/$FILENAME | grep  -E "$FLAG_TO_SEARCH" |wc -l)

	if [ $ERROR_COUNT -gt 5 ]
	then	
 	     echo "We found more than $ERROR_COUNT Invalid format Error on SUM .. Please look $LOG_DIR/$FILENAME"    
	     echo "Please restart application SUM on $HOSTNAME"
	     clean_process
	     exit 2

	else
	     echo " We haven't noticed trouble .. Everything seem OK"
	     clean_process
	     exit 0 
	fi

else
	echo "Script $0 already launched .. so we exit"
fi
