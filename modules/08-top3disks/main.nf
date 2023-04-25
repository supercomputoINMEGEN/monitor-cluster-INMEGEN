/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process topdisk {

    publishDir "${params.intermediates_dir}/08-top3disks/", mode:"symlink"

    input:
        path ZPOOLS
        path SCRIPT

    output:
        path "topdisk.tmp", emit: topdisk_results

    script:
    """
    # remove previous test results
    grep " ONLINE " $ZPOOLS | cut -d" " -f1-5 | sort | uniq > valids.tmp

    # loop trough every uniq connection to get each top3 disks
    while read conn
    do
        ## set routes
        ip="\$(echo \$conn | cut -d' ' -f3)"
        port="\$(echo \$conn | cut -d' ' -f4)"
        user="\$(echo \$conn | cut -d' ' -f5)"
        test_name="top3disks"
        # Usaremos ConnectTimeout 10 para darle 10 segundos al comando para establecer conexion
        (ssh \
        -o ConnectTimeout=10 \
        -i ${params.sshkey} \
        -p \$port \$user@\$ip \
        'bash -s' < $SCRIPT \
        || echo "NA NA") \
        | awk -v info="\$conn \$test_name root" ' BEGIN{ FS=OFS=" "} {print info, \$0}' 
    done < valids.tmp \
    | cat $ZPOOLS - > topdisk.tmp # concat previous test log with this test
   
    """

}

/* name a flow for easy import */
workflow TOPDISK {

    take:
        all_zpools
        scripts_topdisk

    main:        
        topdisk( all_zpools, scripts_topdisk )
    
    emit:
        topdisk.out[0]
}
