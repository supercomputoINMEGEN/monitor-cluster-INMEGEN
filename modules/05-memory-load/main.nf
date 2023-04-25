/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process memload {

    publishDir "${params.intermediates_dir}/05-memory-load/", mode:"symlink"

    input:
        path AVGLOAD
        path SCRIPT

    output:
        path "memload.tmp", emit: memload_results

    script:
    """
    # remove previous test results
    grep " ONLINE " $AVGLOAD | cut -d" " -f1-5 | sort | uniq > valids.tmp

    # loop trough every uniq connection to get each load mem
    while read conn
    do
        ## set routes
        ip="\$(echo \$conn | cut -d' ' -f3)"
        port="\$(echo \$conn | cut -d' ' -f4)"
        user="\$(echo \$conn | cut -d' ' -f5)"
        test_name="load_mem"
        # Usaremos ConnectTimeout 10 para darle 10 segundos al comando para establecer conexion
        (ssh \
        -o ConnectTimeout=10 \
        -i ${params.sshkey} \
        -p \$port \$user@\$ip \
        'bash -s' < $SCRIPT \
        || echo "NA NA") \
        | awk -v info="\$conn \$test_name root" ' BEGIN{ FS=OFS=" "} {print info, \$0}' 
    done < valids.tmp \
    | cat $AVGLOAD - > memload.tmp # concat previous test log with this test
   

    """

}

/* name a flow for easy import */
workflow MEMLOAD {

    take:
        all_avg
        scripts_memload

    main:        
        memload( all_avg, scripts_memload )
    
    emit:
        memload.out[0]
}
