#!/bin/bash

#Scripte gere par Puppet

#scripte qui check si un/des fichier(s) plus vieux de x minutes sont present, et sort en erreur si c'est le cas.

#Initialisation des Variables
usage="./check_file_age_ed.sh <fichier> <fichier_ini de ed> <minutes> \n"

fic=$1
ini_file=$2
min=$3

if [ "$fic" == "all" ] || [ "$fic" == "ALL" ]
then
        fic="*"
fi

#On verifie qu'il ne manque pas de parametres
if [ "$ini_file" == "" ] || [ "$fic" == "" ] || [ "$min" == "" ]
then
        echo "Critical: parametre manquant."
        echo -e $usage
        exit 2
fi

dossier=$(sed -n 's/.*source-directory *= *\([^ ]*.*\)/\1/p' < /etc/tyr.d/${ini_file}.ini)

#On cherche si des fichiers sont present et on stock le resultat dans un fichier log
find  $dossier -maxdepth 1 -name "$fic" -mmin +$min -type f > /tmp/check_file_age.log

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
