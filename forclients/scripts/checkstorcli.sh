#!/bin/bash

# validate if this is a storcli system
if ! command -v storcli64 &> /dev/null
then
    echo "NOT_A_storcli64_SYSTEM________"
    exit
fi

# get the state of the controller
STATUS=$(storcli64 /c0 show all | grep "Status")

if [ "$STATUS" = "Status = Failure" ]
then
    echo "sotrcli64_CONTROLLER_NOT_FOUND________"
    exit
fi

# find lines for info
line_for_VD=$( storcli64 /c0 show all | grep "VD LIST" -n | cut -d":" -f1 )
line_for_PD=$( storcli64 /c0 show all | grep "PD LIST" -n | cut -d":" -f1 )

# echo "[DEBUG] VD line found at $line_for_VD"
# echo "[DEBUG] PD line found at $line_for_PD"

storcli64 /c0 show all \
| sed -n "$line_for_VD,$line_for_PD p" \
| grep -v "=" \
| grep -v "^$" \
| grep "^[0-9]" \
| tr -s " " \
| tr " " "_"
