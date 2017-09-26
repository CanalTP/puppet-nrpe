#!/bin/bash
# DEVOP-1921
# Reload reconcile when memory critical

#Initialisation des Variables
service_status=$1
nb_retry=$2
DEST_MAIL="dt.exploitation@canaltp.fr"


if ( [ "$service_status" != "CRITICAL" ] ) || [ "$nb_retry" != "2" ]
then
        exit 0
fi

sudo /usr/bin/supervisorctl restart kronos:reconcile

echo "Devops,
We found an issue with memory usage so we restarted reconcile kronos processus on ${HOSTNAME}
Thanks."  | mail -s "Auto restart processus reconcile on ${HOSTNAME}" ${DEST_MAIL}

