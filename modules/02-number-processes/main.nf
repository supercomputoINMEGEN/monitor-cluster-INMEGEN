/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process number_processes {

    publishDir "${params.intermediates_dir}/02-number-processes/", mode:"symlink"

    input:
        path VALIDATIONS
        path SCRIPT

    output:
        path "processes.tmp", emit: number_processes_results

    script:
    """
    # remove previous test results
    grep " ONLINE " $VALIDATIONS | cut -d" " -f1-5 | sort | uniq > valids.tmp

    # loop trough every uniq connection to get number of processes
    while read conn
    do
        ## set routes
        ip="\$(echo \$conn | cut -d' ' -f3)"
        port="\$(echo \$conn | cut -d' ' -f4)"
        user="\$(echo \$conn | cut -d' ' -f5)"
        test_name="number_processes"
        # Usaremos ConnectTimeout 10 para darle 10 segundos al comando para establecer conexion
        (ssh \
        -o ConnectTimeout=10 \
        -p \$port \$user@\$ip \
        'bash -s' < $SCRIPT \
        || echo "NA NA NA") \
        | awk -v info="\$conn \$test_name" ' BEGIN{ FS=OFS=" "} {print info, \$0}' 
    done < valids.tmp \
    | cat $VALIDATIONS - > processes.tmp # concat previous test log with this test
   

    """

}

/* name a flow for easy import */
workflow NUMBER_PROCESSES {

    take:
        all_validations
        scripts_number_processes

    main:        
        number_processes( all_validations, scripts_number_processes )
    
    emit:
        number_processes.out[0]
}
