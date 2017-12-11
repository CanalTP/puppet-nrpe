#!/bin/bash
# Script that's useful for checking pureftpd

ENV_VALUE=$(echo $HOSTNAME|cut -d "-" -f 2)

GET_CONNECTED_NBR=$(pure-mrtginfo|awk 'NR==1')
GET_UPTIME_FTP=$(pure-mrtginfo|awk 'NR==3'|awk '{print $1}')


echo "Connected clients: CONNECTED=$GET_CONNECTED_NBR, Uptime server: UPTIME_HOST_FTP=${GET_UPTIME_FTP}j"
exit 0
