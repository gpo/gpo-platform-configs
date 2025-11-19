#!/bin/bash

# This script will look for long running mysql queries being executed by the DB user 'big_query_user'
# which is a read-only account used for exporting data and BI dashboards. This should prevent BI
# from locking up our database.

LOGFILE=/var/log/kill_long_queries.log

function log() {
	echo "$(date) $@" | tee >> ${LOGFILE}
}

# this is the "login path" stored (obfuscated) in ~/.mylogin.cnf
# run `mysql_config_editor print --all` to see the contents of this file
# basically, this is the username we'll use to access the db
MYLOGIN_PATH=forge

# any queries running longer than this will be killed
MAX_QUERY_SECONDS=30

LONG_QUERY_COUNT=$(mysql --login-path=${MYLOGIN_PATH} --skip-column-names --silent --raw --execute \
	"SELECT count(*) FROM information_schema.processlist
	WHERE command <> 'Sleep'
	AND user='big_query_user'
	AND time >= ${MAX_QUERY_SECONDS};")

if [[ "${LONG_QUERY_COUNT}" -gt 0 ]]; then
	log "${LONG_QUERY_COUNT} long running queries by 'big_query_user' found, killing them now..."
else
	log "No long running queries found, exiting."
	exit 0
fi

QUERY="SELECT id,info FROM information_schema.processlist
	WHERE command <> 'Sleep'
	AND user='big_query_user'
	AND time >= ${MAX_QUERY_SECONDS};"

# here we run the above query and iterate over the results in a loop
# extracting the results into the variables "id" and "info"
while read id info
do
	log "Killing long running transaction id: ${id} which is executing SQL statement: ${info}."
	echo "KILL QUERY ${id};" | mysql --login-path=${MYLOGIN_PATH} --skip-column-names --silent --raw
done < <(echo ${QUERY} | mysql --login-path=${MYLOGIN_PATH} --skip-column-names --silent --raw)
