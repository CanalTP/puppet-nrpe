#!/bin/bash
# Script that's useful for checking pureftpd

ENV_VALUE=$(echo $HOSTNAME|cut -d "-" -f 2)

GET_CONNECTED_NBR=$(pure-mrtginfo|awk 'NR==1')
GET_UPTIME_FTP=$(pure-mrtginfo|awk 'NR==3'|awk '{print $1}')
MAX_CLIENT=$(cat /etc/pure-ftpd/conf/MaxClientsNumber)
WARNING_CLIENT=$(( $MAX_CLIENT*80/100))

if [ $GET_CONNECTED_NBR -gt $WARNING_CLIENT ]
then
        echo "CRITICAL:Connected clients: CONNECTED=$GET_CONNECTED_NBR, Uptime server: UPTIME_HOST_FTP=${GET_UPTIME_FTP}j|connected_client=$GET_CONNECTED_NBR"
        exit 2
else
        echo "OK:Connected clients: CONNECTED=$GET_CONNECTED_NBR, Uptime server: UPTIME_HOST_FTP=${GET_UPTIME_FTP}j|connected_client=$GET_CONNECTED_NBR"
        exit 0
fi
exit 3
