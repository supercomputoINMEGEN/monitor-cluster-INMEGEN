#!/bin/bash

# hostname
elhost=$(hostname)

# set time
timestamp=$1

# find users connected
totalcpu=$(nproc)
loadcpu=$(uptime | cut -d"," -f4 | cut -d":" -f2 | tr -d " ")
totalmem=$(free -h --si | grep "Mem:" | tr -s " " | cut -d" " -f2)
usedmem=$(free -h --si | grep "Mem:" | tr -s " " | cut -d" " -f3)
availablediskroot=$(df -h -BG | grep "/\$" | tr -s " " | cut -d" " -f4)
useddiskroot=$(df -h -BG | grep "/\$" | tr -s " " | cut -d" " -f3)

echo "$timestamp $elhost $totalcpu $loadcpu $totalmem $usedmem $availablediskroot $useddiskroot" | tr " " "\t"
