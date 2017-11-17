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
error=0
output=""
log_dir="${logs_root_dir}/${today_date}"


f [ -z "$conteneur_id" ]; then
        printf "OK - Pas de conteneurs stat-logger demarre sur ce noeud"
        exit 0
fi
for id in $conteneur_id
do
        find_content=$(find "${logs_root_dir}/${today_date}" -name "*${id}*.json.log" -type f -mmin +"${files_max_age_in_minutes}" | tr '\n' ' ')

        if [ -z "$find_content" ]; then
                if [ error != 3 ]; then
                        error=0
                fi
        elif [ -n "$find_content" ]; then
                output="${output}CRITICAL - fichier plus vieux que $files_max_age_in_minutes minutes : $find_content\n"
                error=2
        fi
done
if [ "$error" -eq 2 ]; then
        printf "$output"
        exit 2
fi
if [ "$error" -eq 0 ]; then
        printf "OK - Pas de fichier plus vieux que %s minutes."
        exit 0
fi
printf "UNKNOWN: problem dans l'execution de la sonde"
exit 3
