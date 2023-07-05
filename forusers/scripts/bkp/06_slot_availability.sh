#!/bin/bash

# set time
timestamp=$1

# Numbers reported are Total slots, Claimed Nodes, and Unclaimed Nodes
condor_status \
| grep "Total" \
| tr -s " " \
| sed -s "s#^ ##" \
| tail -n1 \
| cut -d " " -f2,4,5 \
| awk -v  time="$timestamp" ' BEGIN{ FS=OFS=" "}
	{print time, $0} ' \
| tr " " "\t"
