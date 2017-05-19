#!/bin/sh

# initial author: Fabien Degomme <fabien.degomme@kisio.org> @devops 19/05/2017
# usage: $0 <logs_root_dir> <files_max_age_in_minutes>

function usage {
	printf "Usage: %s <logs_root_dir> <files_max_age_in_minutes>\n\n" "$0"

	printf "Arguments:\n"
	printf "  * logs_root_dir :\t\tdirectory path where logs are located (<logs_root_dir>/<year>/<month>/<day>/)\n"
	printf "  * files_max_age_in_minutes :\tif files that are older than <files_max_age_in_minutes> minutes are present, send a critical alert)\n\n"

	printf "Example:\n"
	printf "  \`%s /path/to/my/great/json/logs/root/dir 30\`\t→ checks if JSON files in /path/to/my/great/json/logs/root/dir are not older than 30 minutes\n" "$0"

	printf "\nUNKNOWN - Maybe bad arguments, you are in usage function\n"
	exit 3
}

if [[ "$#" -eq 0 ]] || [[ "$#" -gt 2 ]] || [[ "$#" -eq 1 ]]; then
	usage
fi

today_date=$(date +%Y/%m/%d)

logs_root_dir="${1}"
files_max_age_in_minutes="${2}"

log_dir="${logs_root_dir}/${today_date}"

find_content=$(find "${logs_root_dir}/${today_date}" -name "*.json.log" -type f -mmin +"${files_max_age_in_minutes}" | tr '\n' ' ')

if [ -z "$find_content" ]; then
	printf "OK - pas de fichier plus vieux que %s minutes\n" "$files_max_age_in_minutes"
	exit 0
elif [ -n "$find_content" ]; then
	printf "CRITICAL - fichier plus vieux que %s minutes : %s\n" "$files_max_age_in_minutes" "$find_content"
	exit 2
fi

