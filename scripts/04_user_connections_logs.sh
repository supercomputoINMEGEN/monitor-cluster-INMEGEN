#!/bin/bash

# find users connected
who \
| tr -s " " \
| cut -d " " -f1,3,4 \
| sort -k1 -k2 -k3 \
| tr " " "\t"
