#! /bin/bash
function get_TimeTaken
{
        action=${1}
        logs=$(echo "$total_req" | grep -v "^#" | egrep -i "(action=$action|action=Advanced$action)")
        while read line
        do
                timetk=$(echo $line | awk -F " " '{print $NF}')
                ((timetaken_total=$timetaken_total+$timetk))
                ((i=$i+1))
        done <<< "$logs"
        ((moyen=$timetaken_total/$i))
        echo "$moyen"
        
}
file_log=$1
#file_log="/srv/syslog/web/gwsncf-eng.national3"
if [ ! $file_log ]
then
       echo "Vous devez renseigner la chaine de charactere a rechercher"
       exit 3
fi
                                      

h_moins_1min=`date +' %H:%M:' -d '1 minute ago'`
h_moins_2min=`date +' %H:%M:' -d '2 minute ago'`
h_moins_3min=`date +' %H:%M:' -d '3 minute ago'`
h_moins_4min=`date +' %H:%M:' -d '4 minute ago'`
year=`date +'%Y'`
month=`date +'%m'`
day=`date +'%d'`

timetaken_total=0
timetk=0
total_req=`tail -15000 ${file_log}/${year}/${month}/${day}/access.log | egrep "($h_moins_1min|$h_moins_2min|$h_moins_3min|$h_moins_4min)"`

planjourney=`get_TimeTaken "planjourney"`
nextdep=`get_TimeTaken "nextdeparture" `
vehiclejourneydetaillist=`get_TimeTaken "vehiclejourneydetaillist"` 

echo "Temps de reponses sur les 4 dernieres minutes : Planjourney=${planjourney}ms, Nextdeparture=${nextdep}ms, Vehiclejourneydetaillist=${vehiclejourneydetaillist}ms | planjourney=${planjourney}ms, nextdeparture=${nextdep}ms, vehiclejourneydetaillist=${vehiclejourneydetaillist}ms"
exit 0

