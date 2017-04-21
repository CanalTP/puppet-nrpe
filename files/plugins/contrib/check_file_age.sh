#!/bin/bash

#Scripte gere par Puppet

#scripte qui check si un/des fichier(s) plus vieux de x minutes sont present, et sort en erreur si c'est le cas.

#Initialisation des Variables
usage="./check_file_age.sh <dossier> <fichier> <minutes> [non_fic]\n Saisissez non fic pour que si le fichier n'est pas present le scripte sorte en OK"

dossier=$1
fic=$2
min=$3

if [ "$fic" == "all" ] || [ "$fic" == "ALL" ]
then
        fic="*"
fi

#On verifie qu'il ne manque pas de parametres
if [ "$dossier" == "" ] || [ "$fic" == "" ] || [ "$min" == "" ]
then
        echo "Critical: parametre manquant."
        echo -e $usage
        exit 2
fi
if [ "$4" != "non_fic" ]
then
	#On verifie qu'un fichier est present
	if [ "$(ls $dossier/$fic 2>/dev/null)" == "" ]
	then
			echo "Critical: Pas de fichier $fic trouve dans $dossier"
			exit 2
	fi
fi
#On cherche si des fichiers sont present et on stock le resultat dans un fichier log
find  $dossier -maxdepth 1 -type f -name "$fic" -mmin +$min > /tmp/check_file_age.log

#si le fichier log est vide c'est qu'il n'y a pas de fichier
if [ "$?" == "0" ] && [ "$(cat /tmp/check_file_age.log)" == "" ]
then
        echo "OK: Pas de $fic plus vieux de $min minutes dans $dossier."
        rm /tmp/check_file_age.log
        exit 0
fi

#Sinon on quite en erreur
echo "Critical: Fichier(s) plus vieux de $min minutes trouve dans $dossier."
echo $(cat /tmp/check_file_age.log)
rm /tmp/check_file_age.log
exit 2
