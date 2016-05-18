#!/bin/bash

#Scripte gere par Puppet

#Initialisation des Variables
service_status=$1
nb_retry=$2
DEST_MAIL="dt.exploitation@canaltp.fr"


if ( [ "$service_status" != "WARNING" ] && [ "$service_status" != "CRITICAL" ] ) || [ "$nb_retry" != "2" ]
then

        exit 0
fi

sudo /usr/sbin/service apache2 reload
echo "Bonjour,
Erreur detecte, le reload d'apache a ete effectue sur le serveur ${HOSTNAME}

Cordialement."  | mail -s "Reload autommatique d'Apache sur ${HOSTNAME}" ${DEST_MAIL}

