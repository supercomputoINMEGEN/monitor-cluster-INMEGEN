#!/bin/bash

# validate if this is a storcli system
if ! command -v storcli64 &> /dev/null
then
    echo "NOT_A_storcli64_SYSTEM________"
    exit
fi

# get the state of the controller
STATUS=$(storcli64 show all | grep "Status")

if [ "$STATUS" = "Status = Failure" ]
then
    echo "sotrcli64_CONTROLLER_FAILURE_________"
    exit
fi

# Find lines for the segment of interest in the log
startline_for_System_Overview=$( storcli64 show all | grep "System Overview" -n | cut -d":" -f1 )
endline_for_System_Overview=$( storcli64 show all | grep -w "ASO" -n | cut -d":" -f1 )

# echo "$startline_for_System_Overview"
# echo "$endline_for_System_Overview"

valid_controllers=$( storcli64 show all \
| sed -n "$startline_for_System_Overview,$endline_for_System_Overview p" \
| grep -v "=" \
| grep -v "^$" \
| tr -s " " \
| grep "^ " \
| cut -d" " -f2 )

# loop through controllers
for controller in $valid_controllers
do
	# echo "[DEBUG] analyzing controller: $controller"
	$(dirname "$0")/askcontroller.sh $controller
done
