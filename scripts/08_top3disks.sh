#!/bin/bash

# hostname
elhost=$(hostname)

# find resources
df -h | sort -hr -k2 | head -n3 | tr -s " " | cut -d" " -f 3,4,6 \
| awk -v host="$elhost" \
'
	BEGIN{ FS=OFS=" " }
	{ print "used_"$1",available_"$2",disk_"$3, host }
'