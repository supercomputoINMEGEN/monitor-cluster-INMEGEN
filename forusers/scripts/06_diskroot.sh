#!/bin/bash

# hostname
elhost=$(hostname)

# find resources
useddiskroot=$(df -h -BG | grep "/\$" | tr -s " " | cut -d" " -f3)
availablediskroot=$(df -h -BG | grep "/\$" | tr -s " " | cut -d" " -f4)

echo "used_$useddiskroot,available_$availablediskroot" \
| awk -v host="$elhost" \
'
	BEGIN{ FS=OFS=" " }
	{ print $0, host }
'