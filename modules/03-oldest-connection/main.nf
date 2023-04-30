/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process oldest_connection {

    publishDir "${params.intermediates_dir}/03-oldest-connection/", mode:"symlink"

    input:
        path PROCESSES
        path SCRIPT

    output:
        path "oldest_connection.tmp", emit: oldest_connection_results

    script:
    """
    # remove previous test results
    grep " ONLINE " $PROCESSES | cut -d" " -f1-5 | sort | uniq > valids.tmp

    # loop trough every uniq connection to get oldest connections
    while read conn
    do
        ## set routes
        ip="\$(echo \$conn | cut -d' ' -f3)"
        port="\$(echo \$conn | cut -d' ' -f4)"
        user="\$(echo \$conn | cut -d' ' -f5)"
        test_name="oldest_connection"
        # Usaremos ConnectTimeout 10 para darle 10 segundos al comando para establecer conexion
        (ssh \
        -i ${params.sshkey} \
        -o ConnectTimeout=10 \
        -p \$port \$user@\$ip \
        'bash -s' < $SCRIPT \
        || echo "NA NA NA") \
        | awk -v info="\$conn \$test_name" ' BEGIN{ FS=OFS=" "} {print info, \$0}' 
    done < valids.tmp \
    | cat $PROCESSES - > oldest_connection.tmp # concat previous test log with this test
   

    """

}

/* name a flow for easy import */
workflow OLDEST_CONNECTION {

    take:
        all_processes
        scripts_oldest_connection

    main:        
        oldest_connection( all_processes, scripts_oldest_connection )
    
    emit:
        oldest_connection.out[0]
}
