#!/bin/bash

# hostname
elhost=$(hostname)

# find resources
usedmem=$(free -h --si | grep "Mem:" | tr -s " " | cut -d" " -f3)
totalmem=$(free -h --si | grep "Mem:" | tr -s " " | cut -d" " -f2)

echo "$usedmem/$totalmem" \
| awk -v host="$elhost" \
'
	BEGIN{ FS=OFS=" " }
	{ print $0, host }
'