#!/bin/bash
#Script that's useful for checking content laf directories for ko files

ENV_VALUE=$(echo $HOSTNAME|cut -d "-" -f 2)
DATE_TIME=$(date +%F_%T)

NFS_DIRECTORIES="/data/common/laf-nfs/save"

# Needed directories
OK_TRANSMIS=$NFS_DIRECTORIES/OK_transmis


function OK_transmis()
{
	count=$(find $OK_TRANSMIS -type f |wc -l)
        PERFDATA="| OK_TRANSMIS=$count"
}

#Start application
OK_transmis

echo -e "Metrics OK_TRANSMIS $PERFDATA"	
