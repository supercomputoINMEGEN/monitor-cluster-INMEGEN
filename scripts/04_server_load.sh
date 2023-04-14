#!/bin/bash

# hostname
elhost=$(hostname)

# find users connected with desired format
w \
| head -n1 \
| cut -d"," -f 4 \
| cut -d":" -f 2 \
| tr -d " " \
| awk -v host="$elhost" \
'
	BEGIN{ FS=OFS=" " }
	{ print $0, host }
'