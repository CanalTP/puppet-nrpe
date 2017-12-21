#!/bin/bash
# Check if uwsgi service is running correctly

# Format output
function log4bash(){
	echo -e "[${1}] - ${2}"
}

# Get current memory usage
function get_memory_usage(){
	local pid_list=${1}
	local total_mem=0

	for pid in ${pid_list[*]};
	do
		# Get mem
		mem="$(ps --no-headers -p ${pid} -o rss)"
		total_mem=$(( ${total_mem} + ${mem} ))
	done

	# Return value
	echo ${total_mem}
}

# Argument parser
while getopts ":c:" opt;
do
	case ${opt} in
	  c)
		CONFIG_FILE=${OPTARG}
		;;
	  :)
		log4bash "error" "Option -${OPTARG} requires an argument."
		exit 3
	  	;;
	  \?)
		log4bash "error" "Invalid option -${OPTARG}"
		exit 3
		;;
	  *)
		log4bash "error" "argument missing\n$(basename $0) -c uwsgi_config_file"
		exit 3
		;;
	esac
done

# If no argument
if [ $# == 0 ];
then
	log4bash "error" "argument missing\n$(basename $0) -c uwsgi_config_file"
	exit 3
fi

CONFIG_NBR_PROCESS=$(awk '/processes/{print $3}' ${CONFIG_FILE})

# Get current processes
current_pid_process=( $(pidof uwsgi) )

if [ ${#current_pid_process[@]} -lt ${CONFIG_NBR_PROCESS} ];
then
	log4bash "CRITICAL" "uWSGI processes missing | mem=$(get_memory_usage ${current_pid_process})KB;;;; nbr_process=${#current_pid_process[@]};;;;"
	exit 2
else
	# All processes is running
	log4bash "OK" "All uWSGI processes are running | mem=$(get_memory_usage ${current_pid_process})KB;;;; nbr_process=${#current_pid_process[@]};;;;"
fi
