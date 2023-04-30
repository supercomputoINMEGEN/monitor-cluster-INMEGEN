/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process diskroot {

    publishDir "${params.intermediates_dir}/06-diskroot/", mode:"symlink"

    input:
        path MEMS
        path SCRIPT

    output:
        path "diskroot.tmp", emit: diskroot_results

    script:
    """
    # remove previous test results
    grep " ONLINE " $MEMS | cut -d" " -f1-5 | sort | uniq > valids.tmp

    # loop trough every uniq connection to get each rootdisk usage
    while read conn
    do
        ## set routes
        ip="\$(echo \$conn | cut -d' ' -f3)"
        port="\$(echo \$conn | cut -d' ' -f4)"
        user="\$(echo \$conn | cut -d' ' -f5)"
        test_name="load_rootdisk"
        # Usaremos ConnectTimeout 10 para darle 10 segundos al comando para establecer conexion
        (ssh \
        -i ${params.sshkey} \
        -o ConnectTimeout=10 \
        -p \$port \$user@\$ip \
        'bash -s' < $SCRIPT \
        || echo "NA NA") \
        | awk -v info="\$conn \$test_name root" ' BEGIN{ FS=OFS=" "} {print info, \$0}' 
    done < valids.tmp \
    | cat $MEMS - > diskroot.tmp # concat previous test log with this test
   
    """

}

/* name a flow for easy import */
workflow DISKROOT {

    take:
        all_mem
        scripts_diskroot

    main:        
        diskroot( all_mem, scripts_diskroot )
    
    emit:
        diskroot.out[0]
}
