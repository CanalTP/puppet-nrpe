#!/bin/bash
# Script that will check OSM status
# Launched by nrpe
# DEVOPP-400

#Variables
LOG_MONITOR=/var/download/traces/`date +%F`_monitor.log
DATE_TIME=$(date +%F_%T)
MSG_OUTPUT="OSM update report: "

GLOBAL_OK=0
STEP_2=0
STEP_3=0
STEP_4=0
STEP_5=0
STEP_6=0

function check_step_2
{
   cat $LOG_MONITOR |grep -q "STEP-2=KO"
   RET_CODE=$?

   if [ $RET_CODE -eq 0 ];then
           STEP_2=1
           MSG_OUTPUT="$MSG_OUTPUT Backuping file state.txt:[KO]"
   else
           MSG_OUTPUT="$MSG_OUTPUT Backuping file state.txt:[OK]"
   fi
}

function check_step_3
{
   cat $LOG_MONITOR |grep -q "STEP-3=KO"
   RET_CODE=$?

   if [ $RET_CODE -eq 0 ];then
           STEP_3=1
           MSG_OUTPUT="$MSG_OUTPUT Updating file with osmosis:[KO]"
   else
           MSG_OUTPUT="$MSG_OUTPUT Updating file with osmosis:[OK]"
   fi
}

function check_step_4
{
   cat $LOG_MONITOR |grep -q "STEP-4=KO"
   RET_CODE=$?

   if [ $RET_CODE -eq 0 ];then
           STEP_4=1
           MSG_OUTPUT="$MSG_OUTPUT Applying update with osm2psql:[KO]"
   else
           MSG_OUTPUT="$MSG_OUTPUT Applying update with osm2psql:[OK]"
   fi
}

function check_step_5
{
   cat $LOG_MONITOR |grep -q "STEP-5=KO"
   RET_CODE=$?

   if [ $RET_CODE -eq 0 ];then
           STEP_5=1
           MSG_OUTPUT="$MSG_OUTPUT Applying update with osm2psql:[KO]"
   else
           MSG_OUTPUT="$MSG_OUTPUT Applying update with osm2psql:[OK]"
   fi
}


function check_step_6
{
   cat $LOG_MONITOR |grep -q "STEP-6=KO"
   RET_CODE=$?

   if [ $RET_CODE -eq 0 ];then
           STEP_6=1
           MSG_OUTPUT="$MSG_OUTPUT Invalidate cache:[KO]"
   else
           MSG_OUTPUT="$MSG_OUTPUT Invalidate cache:[OK]"
   fi
}

# Launch here
check_step_2
check_step_3
check_step_4
check_step_5
check_step_6

if [ $STEP_2 -eq 0 ] && [ $STEP_2 -eq 0 ] && [ $STEP_3 -eq 0 ] && [ $STEP_4 -eq 0 ] && [ $STEP_5 -eq 0 ] && [ $STEP_6 -eq 0 ];then
        echo "[OSM][REPORT_UPDATE] $MSG_OUTPUT"
        exit 0
else
        echo "[OSM][REPORT_UPDATE] $MSG_OUTPUT"
        exit 2
fi
                                                                                                                                                                                                 
