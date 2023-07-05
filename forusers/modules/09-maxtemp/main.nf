/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process maxtemp {

    publishDir "${params.intermediates_dir}/09-maxtemp/", mode:"symlink"

    input:
        path TOPDISK
        path SCRIPT

    output:
        path "maxtemp.tmp", emit: maxtemp_results

    script:
    """
    # remove previous test results
    grep " ONLINE " $TOPDISK | cut -d" " -f1-5 | sort | uniq > valids.tmp

    # loop trough every uniq connection to get max temp
    while read conn
    do
        ## set routes
        ip="\$(echo \$conn | cut -d' ' -f3)"
        port="\$(echo \$conn | cut -d' ' -f4)"
        user="\$(echo \$conn | cut -d' ' -f5)"
        test_name="maxtemp_C"
        # Usaremos ConnectTimeout 10 para darle 10 segundos al comando para establecer conexion
        (ssh \
        -i ${params.sshkey} \
        -o ConnectTimeout=10 \
        -p \$port \$user@\$ip \
        'bash -s' < $SCRIPT \
        || echo "NA NA") \
        | awk -v info="\$conn \$test_name root" ' BEGIN{ FS=OFS=" "} {print info, \$0}' 
    done < valids.tmp \
    | cat $TOPDISK - > maxtemp.tmp # concat previous test log with this test
   
    """

}

/* name a flow for easy import */
workflow MAXTEMP {

    take:
        all_topdisk
        scripts_maxtemp

    main:        
        maxtemp( all_topdisk, scripts_maxtemp )
    
    emit:
        maxtemp.out[0]
}
