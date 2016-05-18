#!/bin/bash


critical=0 # Variable servant a savoir si il ya eu une erreur durant le script


# test si fichier plus ancien que h-20min dans les differents dossiers "source"
fic_sources=`find /srv/navimake/*/source/* -cmin -20 2> /dev/nul`
if [ "$fic_sources" != "" ]
then 
	echo "CRITICAL : Fichier(s) present dans '/srv/navimake/${region}/source' depuis plus de 20min :"
	echo "$fic_sources"
	critical=1
fi

# test si des fichiers d'erreurs sont presents
fic_erreur=`find /srv/navimake/*/error/* 2> /dev/nul` 
if [ "$fic_erreur" != "" ]
then
	echo "CRITICAL : Fichier(s) present dans '/srv/navimake/${region}/error' :" 
	echo "$fic_erreur"
	critical=1
fi

if [ "$critical" == "0" ] && [ "$fic_sources" == "" ] && [ "$fic_erreur" == "" ]
then
	echo "Ok :ras"
	exit 0
else
	exit 2
fi
