#!/bin/bash

# hostname
elhost=$(hostname)

# find resources
sensors | grep "°C" \
| tr -s " " | cut -d":" -f2 \
| cut -d" " -f2 | grep "°C" \
| tr -d "+" | sed "s#°C##" \
| sort -hr | head -n1 \
| awk -v host="$elhost" \
'
	BEGIN{ FS=OFS=" " }
	{ print $0, host }
'