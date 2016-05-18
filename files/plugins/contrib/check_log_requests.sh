#!/bin/bash
# Return average number of lines inside on a the previous 4 minutes syslog file
# Beware that nagios muse be reading the file
# Use bc (bc), logtail2 (logtail)

log=$1

# FIXME: problem just after midnight...
hour=$(date "+%H")

# take just the last 4 minutes to calculate the average of requests
period=4
one_minute_before=$(date --date="1 minutes ago" "+%M")
two_minutes_before=$(date --date="2 minutes ago" "+%M")
three_minutes_before=$(date --date="3 minutes ago" "+%M")
four_minutes_before=$(date --date="4 minutes ago" "+%M")


if [ $# -eq 1 ]
then

	if [ -r $log ]
	then

		# get the number of lines for the last 4 minutes
		# TODO: maybe use logtail2 to not parse the entire file each time, just the
    # lines never read
		# line ex.: Jan  7 16:50:59 sum-prd-fo3 sum.canaltp.fr: 10.93.4.2 - - [07/Jan/2015:16:50:58 +0100] "GET /services/navitiaV3?wsdl HTTP/1.1" 200 25760 "-" "-" -
		if [ ! -z $3 ]
		then
			nb_requests=$(cat $log | egrep "[[:space:]]$hour:($one_minute_before|$two_minutes_before|$three_minutes_before|$four_minutes_before):" | egrep "$pattern" | grep -v "sumcache-ws.sum.prod.canaltp.prod" | wc --lines)
		else
			nb_requests=$(cat $log | egrep "[[:space:]]$hour:($one_minute_before|$two_minutes_before|$three_minutes_before|$four_minutes_before):" |grep -v "sumcache-ws.sum.prod.canaltp.prod" | wc --lines)
		fi
		nb_requests_by_minute=$(echo $nb_requests/$period | bc)
		echo "$nb_requests_by_minute average requests on the last $period minutes| req_min=$nb_requests_by_minute"
	else
		echo "UNKNOWN: unable to read or non-existent file $log"
		exit 3
	fi
else
	echo "Usage: $0 <logfile>"
	exit 3
fi
