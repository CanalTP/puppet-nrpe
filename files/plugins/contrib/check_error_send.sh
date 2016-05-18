#!/bin/bash
## parsing fichier erreur logs daemon mail et sms

TRESHOLD=1
TRESHOLDMAIL=25
FILEMAIL="/srv/tft/data/log/email_daemon_error_$(date +%d-%m-%Y).log"
FILESMS="/srv/tft/data/log/sms_daemon_error_$(date +%d-%m-%Y).log"

#Check si le dispatcher est actif ou backup
is_backup=$(find /tmp -name supervision.xml -mtime +5 |wc -l)
if [ "$is_backup" -eq "1" ]
then
        echo "OK : Dispatcher backup, le test n'est pas execute"
        exit 0
fi


if [ ! -r "$FILESMS" ] 
	then
	echo "CRITICAL : Logs files are not readable.."
	exit 2
fi

if [ ! -r "$FILEMAIL" ]
	then
	echo "CRITICAL : Logs files are not readable.."
	exit 2
fi

ERRORCOUNTSMS=$(grep  -c '>' $FILESMS)
ERRORCOUNTMAIL=$(grep  -c '>' $FILEMAIL)
#ERRORCOUNTMAIL=$(wc -l $FILEMAIL | cut -d' ' -f1)

if [ $ERRORCOUNTMAIL -gt $TRESHOLDMAIL ] || [ $ERRORCOUNTSMS -gt $TRESHOLD ]
then
    echo -e "CRITICAL : Errors in Log files -> \nmail = $ERRORCOUNTMAIL \nsms = $ERRORCOUNTSMS"
    exit 2 #CRITICAL
else
    echo "OK : not too much errors in log files -> \nmail = $ERRORCOUNTMAIL \nsms = $ERRORCOUNTSMS"
    exit 0
fi