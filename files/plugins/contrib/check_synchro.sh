#!/bin/bash
line="0"
gare="0"
all="0"
repall="0"
scenario="0"

fic_log_line="/srv/www/proxi.regie.canaltp.fr/SiteName/data/logs/cron_line_$(date "+%Y%m%d").log"
fic_log_gare="/srv/www/proxi.regie.canaltp.fr/SiteName/data/logs/cron_gare_$(date "+%Y%m%d").log"
fic_log_affectations="/srv/www/proxi.regie.canaltp.fr/SiteName/data/logs/cron_affectations_$(date "+%Y%m%d").log"
fic_log_repall="/srv/www/proxi.regie.canaltp.fr/SiteName/data/logs//cron_repall_$(date "+%Y%m%d").log"
fic_log_scenario="/srv/www/proxi.regie.canaltp.fr/SiteName/data/logs/cron_scenario_$(date "+%Y%m%d").log"

line=`egrep "^ok$|Synchro Line" $fic_log_line | wc -l`
if [ "$line" != "2" ]
        then
                echo "Erreur dans l'execution du scripte de Syncro des Lignes"
                exit 2
fi

gare=`egrep "^ok$|Synchro Gare" $fic_log_gare | wc -l`
if [ "$gare" != "2" ]
        then
                echo "Erreur dans l'execution du scripte de Syncro des Gares et OD"
                exit 2
fi

affectations=`egrep "^ok$|Synchro Affectations" $fic_log_affectations | wc -l`
if [ "$affectations" != "2" ]
        then
                echo "Probleme dans le scriptes de d'Affectations"
                exit 2
fi

repall=`egrep "^ok$|Export" $fic_log_repall | wc -l`
if [ "$repall" != "2" ] && [  "$repall" != "4" ]
        then
                echo "Probleme dans le scriptes de synchro repall"
                exit 2
fi

scenario=`egrep "^ok$|Export" $fic_log_scenario | wc -l`
if [ "$scenario" != "2" ]
        then
                echo "Probleme dans le scriptes de scenario"
                exit 2
fi

echo "OK: Toutes les Crons sont OK"
