#!/bin/bash

# Define a limit for connections
min_non_offending_processes=5        # to exclude user with less than these processesç
#max_allowed_processes=10 ## default 5

# hostname
elhost=$(hostname)

# set time
timestamp=$1

# find users connected
ps -aux	\
| grep -v "root" \
| grep -v "condor" \
| tr -s " " \
| cut -d " " -f1 \
| sort \
| uniq -c \
| tr -s " " \
| sed -s "s# ##" \
| sort -nr \
| awk \
	-v low_limit="$min_non_offending_processes" \
	-v stamp="$timestamp" \
	-v host="$elhost" \
	'
	BEGIN{ FS=OFS=" " }
	$1 > low_limit { print stamp, $0, host }
	' \
| tr " " "\t"
