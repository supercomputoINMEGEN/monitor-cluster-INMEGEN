/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process load_avg {

    publishDir "${params.results_dir}/04-server-load/", mode:"copyNoFollow"

    input:
        path OLDESTS
        path SCRIPT

    output:
        path "load_avg.tmp", emit: load_avg_results

    script:
    """
    # remove previous test results
    grep " ONLINE " $OLDESTS | cut -d" " -f1-5 | sort | uniq > valids.tmp

    # loop trough every uniq connection to get each load avg
    while read conn
    do
        ## set routes
        ip="\$(echo \$conn | cut -d' ' -f3)"
        port="\$(echo \$conn | cut -d' ' -f4)"
        user="\$(echo \$conn | cut -d' ' -f5)"
        test_name="load_avg_1min"
        # Usaremos ConnectTimeout 10 para darle 10 segundos al comando para establecer conexion
        (ssh \
        -o ConnectTimeout=10 \
        -i ${params.sshkey} \
        -p \$port \$user@\$ip \
        'bash -s' < $SCRIPT \
        || echo "NA NA NA") \
        | awk -v info="\$conn \$test_name root" ' BEGIN{ FS=OFS=" "} {print info, \$0}' 
    done < valids.tmp \
    | cat $OLDESTS - > load_avg.tmp # concat previous test log with this test
   

    """

}

/* name a flow for easy import */
workflow LOAD_AVG {

    take:
        all_oldest
        scripts_load_avg

    main:        
        load_avg( all_oldest, scripts_load_avg )
    
    emit:
        load_avg.out[0]
}
