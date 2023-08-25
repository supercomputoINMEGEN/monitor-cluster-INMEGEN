/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */

process splitvalids {

    input:
        path GROUPS
    
    output:
        path "chunk_*.tmp"

    script:
    """
    # find ONLINE nodes
    grep " ONLINE " $GROUPS | cut -d" " -f1-5 | sort | uniq \
    | split -l 1 -d - --additional-suffix=".tmp" "chunk_"
    """
}

process storcli {

     input:
         path CHUNK

     output:
         path "*.storcli*"

    script:
    """
    conn=\$(cat $CHUNK)
    
    ## set routes
    ip="\$(echo \$conn | cut -d' ' -f3)"
    port="\$(echo \$conn | cut -d' ' -f4)"
    user="\$(echo \$conn | cut -d' ' -f5)"
    test_name="storcli"

    # Usaremos ConnectTimeout 10 para darle 10 segundos al comando para establecer conexion
    testresult=\$( ssh \
        -i ${params.sshkey} \
        -o ConnectTimeout=10 \
        -p \$port \$user@\$ip \
        'sudo ~/monitor-cluster-INMEGEN/forclients/scripts/checkstorcli.sh' \
    || echo "NA" )

    # le damos formato a la respuesta final
    # le voy a agregar un NA al final para que no se descuadre con el numero de columnas de resultados de modulos anteriores
    echo "\$conn \$test_name root \$testresult NA" > $CHUNK".storcli.tmp"
    """
}

process gather_storcli {

     publishDir "${params.results_dir}/12-storcli/", mode:"copyNoFollow"

     input:
         path ALLCHUNKS

     output:
         path "allstorcli.tmp", emit: storcli_results 

    script:
    
    """
    cat chunk_*storcli.tmp > allstorcli.tmp
    """

}

/* name a flow for easy import */
workflow STORCLI {

    take:
        all_groups

    main:        
        split_res = splitvalids( all_groups ) | flatten | storcli
        split_res
        .toList()
        | gather_storcli
    
    emit:
        gather_storcli.out[0]

}