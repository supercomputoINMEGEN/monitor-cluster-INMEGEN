#!/bin/bash

# set time
timestamp=$1

condor_q -all \
| grep "ID:" \
| awk -v  time="$timestamp" ' BEGIN{ FS=OFS=" "}
	{print time, $1, $4, $6, $7, $8, $9} ' \
| tr " " "\t"
