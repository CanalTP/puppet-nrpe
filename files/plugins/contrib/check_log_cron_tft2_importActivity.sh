#!/bin/bash

#Scripte de parsing de la log du Crons TFT2 importActivity

##############################
#Initialisation des Variables#
##############################

#Le fichier de log est passe en parametre
fic_log="/srv/tft/backofficeIhmTFT2/current/TftBackoffice/Data/Logs/importActivity.log"

#Le nombre de x dernieres lignes du fichier log a analyser
nb_region=$1

#################
#Debut du Script#
#################

#on parse le fichier et On compte le nombre de fois où la phrase "correctement ex" est presente
res_ok=`cat $fic_log |  grep "correctement ex" | wc -l`

#On quite en erreur, si l'on arrive pas a parser la log
if [ "$?" == "2" ]
then
        echo "CRITICAL : Probleme lors de la lecture du fichier log."
        exit 2
fi

#si la phrase "correctement ex" n'est pas present pour chaque region on quite en erreur
if [ "$res_ok" != "$nb_region" ]
then
        echo  "CRITICAL : Erreur dans la Cron importActivity. "
        echo $res_log
        exit 2
fi

echo "OK : Pas d'erreur detectee dans le fichier log."
exit 0
