#!/bin/bash
# just a wrapper to /usr/lib/nagios/plugins/check_mysql plugin
#
# don't want to pass mysql passwords on command line,
# get /etc/mysql/nagios.cnf file content instead
# (used by other plugins)

mysql_nagios_cnf=$1

if [ -f $mysql_nagios_cnf ]
then
  # sed to ensure no spaces
  # ex.: "user=myuser", "user = myuser"
  user=$(grep "user" $mysql_nagios_cnf | awk -F "=" '{print $2}' | sed "s/[[:space:]]*//")
  password=$(grep "password" $mysql_nagios_cnf | awk -F "=" '{print $2}' | sed "s/[[:space:]]*//")
  /usr/lib/nagios/plugins/check_mysql --username=$user --password=$password --check-slave
  exit $?
else
        echo "$mysql_nagios_cnf does not exist"
        exit 1
fi
