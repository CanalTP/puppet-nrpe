#!/bin/bash
#Script that's useful for checking content laf directories for ko files

ENV_VALUE=$(echo $HOSTNAME|cut -d "-" -f 2)
DATE_TIME=$(date +%F_%T)

NFS_DIRECTORIES="/data/common/laf-nfs/save"

# Needed directories
KO_DOUBLONS=$NFS_DIRECTORIES/KO_doublons
KO_PAS_TRANSMIS=$NFS_DIRECTORIES/KO_pas_transmis
KO_SCHEMA_INVALID=$NFS_DIRECTORIES/KO_schema_invalid
OK_TRANSMIS=$NFS_DIRECTORIES/OK_transmis


function KO_doublons()
{
	count=$(find $KO_DOUBLONS -type f |wc -l)
        PERFDATA="| KO_doublons=$count"
}

function KO_pas_transmis()
{
	count=$(find $KO_PAS_TRANSMIS -type f |wc -l)
	PERFDATA="$PERFDATA KO_PAS_TRANSMIS=$count"
}

function KO_schema_invalid()
{
	count=$(find $KO_SCHEMA_INVALID -type f |wc -l)
	PERFDATA="$PERFDATA KO_SCHEMA_INVALID=$count"
}

function OK_transmis()
{
	count=$(find $OK_TRANSMIS -type f |wc -l)
        PERFDATA="$PERFDATA OK_TRANSMIS=$count"
}

#Start application
KO_doublons
KO_pas_transmis
KO_schema_invalid
OK_transmis

echo -e "Metrics $PERFDATA"	
