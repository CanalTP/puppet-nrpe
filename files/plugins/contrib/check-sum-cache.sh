#!/bin/bash
# Check if url cache response

URL_TO_CHECK="http://localhost/api/v4/admin/rechercherListeConfigurations?typeConfiguration=TECHNIQUE"
DEST_MAIL="mady.camara@canaltp.fr"
#DEST_MAIL="dt.exploitation@canaltp.fr"
OUTPUT_FILE="/tmp/${HOSTNAME}.xml"

SUBJECT_MAIL="Checking sum cache instance ${HOSTNAME}"

unset http_proxy
RET_CODE=$(curl -H 'Host:'${HOSTNAME}'.canaltp.fr' -u "debug:debug"  ${URL_TO_CHECK} -s -o ${OUTPUT_FILE} -w "%{http_code}")

if [ ${RET_CODE} -eq 200 ];then
         echo "[$HOSTNAME][CHECK_SUM_API] Service sum [ok]"
         exit 0
else
	 echo "[$HOSTNAME][CHECK_SUM_API] Service sum [KO] .. Check url:$URL_TO_CHECK"
	 echo "Bonjour,
	       Le check URL:$URL_TO_CHECK renvoit un bad format .
	       Cordialement" | mail -s "${SUBJECT_MAIL}" ${DEST_MAIL}

	 exit 1
fi
