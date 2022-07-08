#!/bin/bash

# Define a limit for connections
max_allowed_processes=10 ## default 10

# find users connected
ps -aux	\
| grep -v "root" \
| tr -s " " \
| cut -d " " -f1 \
| sort \
| uniq -c \
| tr -s " " \
| sed -s "s# ##" \
| sort -nr \
| awk -v limit=$max_allowed_processes \
	'
	BEGIN{ FS=OFS=" " }
	$1 > limit { print $0 }
	' \
> offending_number_of_processes.txt
