#!/bin/bash

# hostname
elhost=$(hostname)

# find resources
cat /etc/passwd \
| tr -s " " | tr " " "_" \
| awk -v host="$elhost" \
'
	BEGIN{ FS=OFS=" " }
	{ print $0, host }
'