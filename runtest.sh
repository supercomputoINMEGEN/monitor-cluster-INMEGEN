#input_conn="conexioninfo/local.txt"
#input_conn="conexioninfo/remote.txt"
output_directory="monitor-results"

# get the date to stamp the data
current_date=$(date "+%Y-%m-%d_%H:%M")

echo -e "======\n Testing NF execution \n======" \
&& rm -rf $output_directory \
&& rm -rf work \
&& nextflow run main.nf \
	--output_dir	"$output_directory" \
	--timestamp $current_date \
	-resume \
	-with-report $output_directory/`date +%Y%m%d_%H%M%S`_report.html \
	-with-dag $output_directory/`date +%Y%m%d_%H%M%S`.DAG.html \
&& echo -e "======\n Basic pipeline TEST SUCCESSFUL \n======"
