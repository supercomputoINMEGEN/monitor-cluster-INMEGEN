/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process getgroups {

    publishDir "${params.results_dir}/10-getgroups/", mode:"copyNoFollow"

    input:
        path USERS
        path SCRIPT

    output:
        path "allgroups.tmp", emit: getgroups_results

    script:
    """
    # remove previous test results
    grep " ONLINE " $USERS | cut -d" " -f1-5 | sort | uniq > valids.tmp

    # loop trough every uniq connection to get all groups
    while read conn
    do
        ## set routes
        ip="\$(echo \$conn | cut -d' ' -f3)"
        port="\$(echo \$conn | cut -d' ' -f4)"
        user="\$(echo \$conn | cut -d' ' -f5)"
        test_name="groups"
        # Usaremos ConnectTimeout 10 para darle 10 segundos al comando para establecer conexion
        (ssh \
        -i ${params.sshkey} \
        -o ConnectTimeout=10 \
        -p \$port \$user@\$ip \
        'bash -s' < $SCRIPT \
        || echo "NA NA") \
        | awk -v info="\$conn \$test_name root" ' BEGIN{ FS=OFS=" "} {print info, \$0}' 
    done < valids.tmp \
    | cat $USERS - > allgroups.tmp # concat previous test log with this test
   
    """

}

/* name a flow for easy import */
workflow GETGROUPS {

    take:
        all_users
        scripts_getgroups

    main:        
        getgroups( all_users, scripts_getgroups )
    
    emit:
        getgroups.out[0]
}
