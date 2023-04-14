#!/bin/bash

# hostname
elhost=$(hostname)

# find users connected with desired format
w \
| tail -n+3 \
| tr -s " " \
| cut -d" " -f1,4 \
| awk -v host="$elhost" \
'
	BEGIN{ FS=OFS=" " }
	{ print $0, host }
'