#!/bin/bash

###
# TODO:
# - run openssl on certificate to get end date.
# - Check if end date not > date

# Take cert file as parameters.
cert_file="${1}"
date_limit="$(date -d "1 months ago" +%s)"

function log4bash(){
	local log_lvl="${1}"
	local mess="${2}"

	case ${log_lvl} in
		"warn")
			exit_code=1
			;;
		"error")
			exit_code=2
			;;
		*)
			exit_code=0
			;;
	esac
	
	# Print message
	echo -e "${mess}"
		
}

if [ -z ${cert_file} ];
then
	log4bash "error" "Parameters missing: ${0} certificate_file"
	exit ${exit_code}	
fi

# Get certificate end date.
certificate_enddate="$(openssl x509 -enddate -noout -in "${cert_file}" | cut -d '=' -f2)"

# Compare date
if [ $(date -d "${certificate_enddate}" +%s) -lt ${date_limit} ];
then
	log4bash "error" "Certificate will espire soon ${certificate_enddate}."
else
	log4bash "info" "Certificate end date ok (expire on ${certificate_enddate})."
fi

exit ${exit_code}
