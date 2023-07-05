#!/bin/bash

# hostname
elhost=$(hostname)

# find resources
zpool list \
| tail -n+2 \
| tr -s " " \
| tr " " "_" \
| awk -v host="$elhost" \
'
	BEGIN{ FS=OFS=" " }
	{ print $0, host }
'