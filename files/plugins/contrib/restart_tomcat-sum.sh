#!/bin/bash

#Scripte gere par Puppet

#Initialisation des Variables
service_status=$1
nb_retry=$2
DEST_MAIL="dt.exploitation@canaltp.fr"


if ( [ "$service_status" != "WARNING" ] && [ "$service_status" != "CRITICAL" ] ) || [ "$nb_retry" != "3" ]
then

        exit 0
fi

sudo service tomcat7-sum restart
echo "Bonjour,
Load eleve detecte, le redemarrage de TOMCAT-SUM a ete effectue sur le serveur ${HOSTNAME}

Cordialement."  | mail -s "Redemarrage automatique de Tomcat-SUM sur ${HOSTNAME}" ${DEST_MAIL}
