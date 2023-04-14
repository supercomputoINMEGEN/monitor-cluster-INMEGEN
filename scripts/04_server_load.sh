#!/bin/bash

# hostname
elhost=$(hostname)

# find users connected with desired format
loadcpu=$(uptime | cut -d"," -f4 | cut -d":" -f2 | tr -d " ")
totalcpu=$(nproc)
echo "$loadcpu/$totalcpu" \
| awk -v host="$elhost" \
'
	BEGIN{ FS=OFS=" " }
	{ print $0, host }
'