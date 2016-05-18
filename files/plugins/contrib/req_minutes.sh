#! /bin/bash

coverage=$1

if [ ! $coverage ]
then
        echo "Vous devez renseigner la chaine de charactere a rechercher"
        exit 3
fi
h_moins_1min=`date +' %H:%M:' -d '1 minute ago'`
h_moins_2min=`date +' %H:%M:' -d '2 minute ago'`
h_moins_3min=`date +' %H:%M:' -d '3 minute ago'`
h_moins_4min=`date +' %H:%M:' -d '4 minute ago'`


total_req=`tail -50000 /var/log/jormungandr/jormungandr.log | grep -i "$1" | egrep "($h_moins_1min|$h_moins_2min|$h_moins_3min|$h_moins_4min)"| wc -l`

req_min=$(echo "scale=2;x=$total_req / 4; if(x<1) print 0; x" | bc -l)


echo "$req_min requetes par minutes de moyenne sur les 4 derniere minutes. | req_min=$req_min"
exit 0

