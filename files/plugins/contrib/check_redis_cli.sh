#!/bin/bash

url_redis=$1

#call redis with CLI and ask info cmd
response=$(redis-cli -h ${url_redis} info 2>&1)
#if exit code is 0 is OKa else we print the error msg
if [ "$?" == "0" ]
then
        echo "Ok: Connection a redis OK."
        exit 0
elif [ "$?" == "1" ]
then
        echo "Critical: probleme de connection a redis:"
        echo ${response}
        exit 2
else
        echo "Unknown : Erreur lors de l'execution de la sonde:"
        echo ${response}
        exit 3
fi
