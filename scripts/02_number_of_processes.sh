#!/bin/bash

# hostname
elhost=$(hostname)

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
| awk -v host="$elhost" \
'
	BEGIN{ FS=OFS=" " }
	{ print $2, $1, host }
'