#!/bin/bash

#Scripte de parsing de log des Crons TFT2

##############################
#Initialisation des Variables#
##############################

#Le fichier de log est passe en parametre
fic_log="/srv/tft/tft-prd-bo/shared/log/$1"
ligne_ok="$2"

#Le nombre de x dernieres lignes du fichier log a analyser
nb_lignes="$3"


#################
#Debut du Script#
#################

#on grep les x dernieres lignes
res_log=$(tail -$nb_lignes  $fic_log)

#On quite en erreur, si l'on arrive pas a parser la log
if [ "$?" == "1" ]
then
        echo "CRITICAL : Probleme lors de la lecture du fichier log."
        exit 2
fi

#On verifie que la phrase "bien deroulee" est bien presente
res_ok=`echo $res_log | grep "$ligne_ok"`

#si la phrase a chercher n'est pas present on quite en erreur
if [ "$res_ok" == "" ]
then
        echo  "CRITICAL : Erreur dans le fichier log:"
        echo $res_log
        exit 2
fi

echo "OK : Pas d'erreur detectee dans le fichier log."
exit 0
