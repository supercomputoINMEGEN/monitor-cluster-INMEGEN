/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process getusers {

    publishDir "${params.intermediates_dir}/10-getusers/", mode:"symlink"

    input:
        path TEMPS
        path SCRIPT

    output:
        path "allusers.tmp", emit: getusers_results

    script:
    """
    # remove previous test results
    grep " ONLINE " $TEMPS | cut -d" " -f1-5 | sort | uniq > valids.tmp

    # loop trough every uniq connection to get all users
    while read conn
    do
        ## set routes
        ip="\$(echo \$conn | cut -d' ' -f3)"
        port="\$(echo \$conn | cut -d' ' -f4)"
        user="\$(echo \$conn | cut -d' ' -f5)"
        test_name="users"
        # Usaremos ConnectTimeout 10 para darle 10 segundos al comando para establecer conexion
        (ssh \
        -i ${params.sshkey} \
        -o ConnectTimeout=10 \
        -p \$port \$user@\$ip \
        'bash -s' < $SCRIPT \
        || echo "NA NA") \
        | awk -v info="\$conn \$test_name root" ' BEGIN{ FS=OFS=" "} {print info, \$0}' 
    done < valids.tmp \
    | cat $TEMPS - > allusers.tmp # concat previous test log with this test
   
    """

}

/* name a flow for easy import */
workflow GETUSERS {

    take:
        all_temp
        scripts_getusers

    main:        
        getusers( all_temp, scripts_getusers )
    
    emit:
        getusers.out[0]
}
