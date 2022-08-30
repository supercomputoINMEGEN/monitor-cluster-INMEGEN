#!/bin/bash

# hostname
elhost=$(hostname)

# set time
timestamp=$1

# find users connected
who \
| tr -s " " \
| cut -d " " -f1,3,4,5 \
| sort -k1 -k2 -k3 -k4 \
| awk \
	-v host="$elhost" \
	'
	BEGIN{ FS=OFS=" " }
	{ print $0, host }
	' \
| tr " " "\t" \
