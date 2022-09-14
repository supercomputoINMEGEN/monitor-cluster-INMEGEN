#!/bin/bash

# hostname
elhost=$(hostname)

# set time
timestamp=$1

# run smem on all users
sudo smem -u -p \
| tr -d "%" \
| tr -s " " \
| awk \
	-v stamp="$timestamp" \
	-v host="$elhost" \
	'
	BEGIN { FS=OFS=" "}
	{print stamp, $1, $5, host}
	' \
| tail -n+2 \
| tr " " "\t"
