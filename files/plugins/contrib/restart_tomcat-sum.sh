#!/bin/bash

#Scripte gere par Puppet

#Initialisation des Variables
service_status=$1
nb_retry=$2
restart_reason=$3

DEST_MAIL="dt.exploitation@canaltp.fr"
SUBJECT_MAIL="Redemarrage automatique de Tomcat-SUM sur ${HOSTNAME}"

if ( [ "$service_status" != "WARNING" ] && [ "$service_status" != "CRITICAL" ] ) || [ "$nb_retry" != "3" ]
then

        exit 0
fi

sudo service tomcat7-sum restart

echo "Bonjour,
Alerte ${restart_reason}, le service tomcat-sum a ete relance sur ${HOSTNAME}.

Cordialement" | mail -s "${SUBJECT_MAIL}" ${DEST_MAIL}

