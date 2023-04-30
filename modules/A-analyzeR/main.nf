/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process analyzer {

    publishDir "${params.results_dir}/A-analyzeR/", mode:"copyNoFollow"

    input:
        path GROUPS
        path SCRIPT

    output:
        path "*.rds", emit: analyzer_results
        path "*.tsv.gz"

    script:
    """
    Rscript --vanilla A_analyze.R \
        $GROUPS \
        ${params.timestamp}
    """

}

/* name a flow for easy import */
workflow ANALYZER {

    take:
        all_groups
        scripts_analyzer

    main:        
        analyzer( all_groups, scripts_analyzer )
    
    emit:
        analyzer.out[0]
}
