/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process recordconfig {

    publishDir "${params.results_dir}/Z-recordconfigs/", mode:"copyNoFollow"

    input:
        path CONFIG

    output:
        path "*"

    script:
    """
    (
    echo "===== nextflow.config ====="
    cat $CONFIG 
    echo "===== END OF CONFIG ====="
    echo "===== ENV variables ====="
    echo "user: $USER"
    echo "home: $HOME"
    ) > configs.txt
    """

}

/* name a flow for easy import */
workflow RECORDCONFIG {

    take:
        nfconfig

    main:        
        recordconfig( nfconfig )

}
