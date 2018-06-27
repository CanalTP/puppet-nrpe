#!/bin/bash
# Monitoring microservice 
#
# Things to know : 
#  - You can specify multiple microservice inside that check. They must be concatenated with a comma
#  - If only one microservice is failed, everything is considered as failed
 
######################
# Variables definitions
###########
MICROSERVICE_RISE_AN_ERROR=0
MSG_OUTPUT="Scanning microservice report: "
DATE_TIME=$(date +%F_%T)


######################
# Check if no arguments has been past
###########
if [[ -z $1 || $1 == "--help" || $1 == "-h" ]]
then
  echo -e "ERROR : You must specify an argument. Running services are : $(docker service ls | awk '{print $2}' | tail -n+2  | xargs)\n"
  echo -e "If you need to check multiple services at once, concatenate them with a comma ','"
  echo -e "Example : $0 service1,service2,..."
  exit 1
else
  LIST_MICROSERVICE=$(echo $1 | sed 's/,/ /g')
fi


######################
# Uniq function to check all microservice at once
###########
function check_microservice()
{
  logger "[$DATE_TIME] Checking if microservice $MICROSERVICE is up"
  GET_SRV_STARTED=$(docker -H localhost:2375 service ps $MICROSERVICE | grep -ivE "remove|shutdown" | tail -n+2 | grep "Running")

  if [ -z "$GET_SRV_STARTED" ]
  then
    MICROSERVICE_RISE_AN_ERROR=1
    MSG_OUTPUT="$MSG_OUTPUT $MICROSERVICE:[KO]"
  else
    MSG_OUTPUT="$MSG_OUTPUT $MICROSERVICE:[OK]"
  fi
}


#####################
# For each microservices, we check his status
###########
for MICROSERVICE in $LIST_MICROSERVICE
do
  check_microservice $MICROSERVICE
done


#####################
# Handling RISEN_AN_ERROR
###########
if [ $MICROSERVICE_RISE_AN_ERROR -eq 0 ] 
then
  echo "$MSG_OUTPUT"
  exit 0
else
  echo "$MSG_OUTPUT"
  exit 2
fi
