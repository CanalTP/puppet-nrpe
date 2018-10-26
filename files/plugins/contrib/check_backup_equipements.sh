#!/bin/bash

#
# File managed by puppet, don't edit directly
#

###############################################################################################
#Scipt du supervision des sauvegardes des equipements "les sauvegardes sont lancee via cron"#
###############################################################################################

#Chemin ou se trouve les dossiers des backups
chemin=/srv/backups

#Liste des equipements (dossiers des backup)
equipement="f5 palo_alto fortigate ucs sw"

#Liste des fichiers par equipement
# Before update 26/10
#fortigate="fortigate-pa4-fw1-adm.canaltp.prod"
#sw="pa4-n5k1-prd.canaltp.prod pa4-n5k2-prd.canaltp.prod ctp-prd-vsm2.canaltp.prod pa4-sw1-prd.canaltp.prod-running-config pa4-sw1-prd.canaltp.prod-vlan.dat pa4-sw1-adm.canaltp.prod-running-config pa4-sw1-adm.canaltp.prod-vlan.dat"
f5="pa4-lc1-prd.canaltp.prod pa4-lc2-prd.canaltp.prod pa4-adc1-prd.canaltp.prod pa4-adc2-prd.canaltp.prod"
palo_alto="pa4-fw1-prd.canaltp.prod pa4-fw2-prd.canaltp.prod"
#old uscs check modif by hakim benyaacoub ucs="ucs.export ucs.backup"
ucs="ucs.export-PA4 ucs.backup-PA4 ucs.export_PA2 ucs.backup_PA2"

sw="pa4-n5k1-prd.canaltp.prod pa4-n5k2-prd.canaltp.prod pa4-sw1-prd.canaltp.prod-running-config pa4-sw1-prd.canaltp.prod-vlan.dat pa4-sw1-adm.canaltp.prod-running-config pa4-sw1-adm.canaltp.prod-vlan.dat"

erreur=3
erreur_out="Critical : problemes de sauvegarde:"

#On Boucle sur chaque equipements
for equi in ${equipement}
do
        if [ ! -d "${chemin}/${equi}" ]
        then
                echo "Critical : Dossier $equi manquant."
                exit 2
                fi
        eval eq=\$$equi
#On boucle sur chaque fichiers de l'equipement sur lequel on est
        for fic in ${eq}
        do
#On cherche si il existe des fichier demoin de 24h et on stock la liste dans la variable result
                result=$(find ${chemin}/${equi}/ -name ${fic}* -mtime -1)

#si la liste des fichiers est vide, on est en erreur
        if [ "$result" != "" ] && [ "$erreur" != "1" ]
        then
                erreur=0
        fi
        if [ "$result" == "" ]
        then

                        erreur_out="$erreur_out \nErreur pas de sauvegarde pour $fic depuis plus de 24h"
                        erreur=1
        fi
        done
done

if [ "$erreur" == "1" ]
then
        echo -e $erreur_out
        exit 1
fi
if [ "$erreur" == "0" ]
then
  echo "OK: Les sauvegardes des equipements sont OK"
  exit 0
fi
echo "Unknown : probleme lors de la recuperation des sauvegardes"
exit 3

