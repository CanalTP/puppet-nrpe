#!/bin/bash

#Scripte gere par Puppet

#Initialisation des Variables
service_status=$1
nb_retry=$2
restart_reson=$3 

DEST_MAIL="dt.exploitation@canaltp.fr"
SUBJECT_MAIL="Redemarrage automatique de Tomcat-SUM sur ${HOSTNAME}"

# Define body message
case ${restart_reson} in
  "load")
    body="Bonjour,
Load eleve detecte, le redemarrage de TOMCAT-SUM a ete effectue sur le serveur ${HOSTNAME}

Cordialement."
    ;;
  "datetime")
    body="Bonjour
Les valeur des clés dateHeure dans la réponse json de ${HOSTNAME} n'est pas valide. Restart du serveur.

Cordialement."
    ;;
esac


if ( [ "$service_status" != "WARNING" ] && [ "$service_status" != "CRITICAL" ] ) || [ "$nb_retry" != "3" ]
then

        exit 0
fi

sudo service tomcat7-sum restart

echo "${body}"  | mail -s "${SUBJECT_MAIL}" ${DEST_MAIL}
