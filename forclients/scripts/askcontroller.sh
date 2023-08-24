#!/bin/bash
n_controller="$1"

#echo "[DEBUG] asking for controller: $n_controller"

# find lines for info
line_for_VD=$( storcli64 /c$n_controller show all | grep "VD LIST" -n | cut -d":" -f1 )
line_for_PD=$( storcli64 /c$n_controller show all | grep "PD LIST" -n | cut -d":" -f1 )

#echo "[DEBUG] VD line found at $line_for_VD"
#echo "[DEBUG] PD line found at $line_for_PD"

# if no VD line is found, exit script
if [ "$line_for_VD" = "" ]
then
    exit
fi

# echo "[DEBUG] printing VD info"
storcli64 /c$n_controller show all \
| sed -n "$line_for_VD,$line_for_PD p" \
| grep -v "=" \
| grep -v "^$" \
| grep "^[0-9]" \
| tr -s " " \
| tr " " "_"
