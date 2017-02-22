#!/bin/bash
#Monitoring if backup mongo is healthy 
 
BACKUP_DIR="/var/backups/$(date +%F)"
MONITOR_FILE=$BACKUP_DIR/supervision.txt

function check_if_backup_was_correct()
{ 
    logger "[$DATE_TIME] Checking if backup mongo was correct"
    FAILED_LIST=$(cat $MONITOR_FILE |grep -i "KO"|tr -d "\n")
    RET_CODE=$?



    if [ $RET_CODE -eq 0 ];then
        echo "[MONGO_BACKUP][$HOSTNAME] Processus failure when backup $FAILED_LIST"
        exit 1
    else
        echo "[MONGO_BACKUP][$HOSTNAME] Processus backup is good"
        exit 0
   fi
}

#Call functions
check_if_backup_was_correct
