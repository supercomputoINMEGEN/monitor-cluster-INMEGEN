/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process zpools {

    publishDir "${params.intermediates_dir}/07-zpools/", mode:"symlink"

    input:
        path DISKROOT
        path SCRIPT

    output:
        path "zpools.tmp", emit: zpools_results

    script:
    """
    # remove previous test results
    grep " ONLINE " $DISKROOT | cut -d" " -f1-5 | sort | uniq > valids.tmp

    # loop trough every uniq connection to get each zpool status
    while read conn
    do
        ## set routes
        ip="\$(echo \$conn | cut -d' ' -f3)"
        port="\$(echo \$conn | cut -d' ' -f4)"
        user="\$(echo \$conn | cut -d' ' -f5)"
        test_name="zpool_list;NAME_SIZE_ALLOC_FREE_EXPANDSZ_FRAG_CAP_DEDUP_HEALTH_ALTROOT"
        # Usaremos ConnectTimeout 10 para darle 10 segundos al comando para establecer conexion
        (ssh \
        -o ConnectTimeout=10 \
        -p \$port \$user@\$ip \
        'bash -s' < $SCRIPT \
        || echo "NA NA") \
        | awk -v info="\$conn \$test_name root" ' BEGIN{ FS=OFS=" "} {print info, \$0}' 
    done < valids.tmp \
    | cat $DISKROOT - > zpools.tmp # concat previous test log with this test
   
    """

}

/* name a flow for easy import */
workflow ZPOOLS {

    take:
        all_diskroot
        scripts_zpools

    main:        
        zpools( all_diskroot, scripts_zpools )
    
    emit:
        zpools.out[0]
}
