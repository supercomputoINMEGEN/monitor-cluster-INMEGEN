#!/bin/bash
# get the dir to shiny codebase
monitor_dir=$(dirname $0)

# move shell to codebase dir
cd "$monitor_dir"

# get the date to stamp the data
current_date=$(date "+%Y-%m-%d_%H:%M")

output_directory="monitor-results"

# remove old workdir
rm -rf work \
&& nextflow run main.nf \
  --output_dir "$output_directory" \
  --timestamp  $current_date
