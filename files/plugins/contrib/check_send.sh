#!/bin/bash

#Check si le dispatcher est actif ou backup
is_backup=$(find /tmp -name supervision.xml -mtime +5 |wc -l)
if [ "$is_backup" -eq "1" ]
then
        echo "OK : Dispatcher backup, le test n'est pas execute"
        exit 0
fi

# Check si il n'y a pas de mails ou de sms en attentes depuis plus de 5 minutes
DIRSMS="/srv/tft/data/sms"
DIRMAIL="/srv/tft/data/email"
ERRORCOUNTSMS=$(find $DIRSMS -type f -cmin +5 | wc -l)
ERRORCOUNTMAIL=$(find $DIRMAIL -type f -cmin +5 | wc -l)

if [ $ERRORCOUNTMAIL -ne 0 ] || [ $ERRORCOUNTSMS -ne 0 ]
then
		echo "CRITICAL : mails or sms not sent since 5 minutes #### mails = $ERRORCOUNTMAIL / sms = $ERRORCOUNTSMS ####"
		exit 2
else
		echo "OK : mails and sms are sent" 
		exit 0
fi 