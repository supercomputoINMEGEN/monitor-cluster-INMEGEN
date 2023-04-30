/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process rmd_report {

    publishDir "${params.results_dir}/B-rmdreports/", mode:"copyNoFollow"

    input:
        path LOGS
        path SCRIPTS

    output:
        path "*.pdf"

    script:
    """
    Rscript --vanilla B_runthermd.R \
        B_R1_reporte_uso_inadecuado_nodos.Rmd
    """

}

/* name a flow for easy import */
workflow RMD_REPORT {

    take:
        all_logsgz
        scripts_rmd_reports

    main:        
        rmd_report( all_logsgz, scripts_rmd_reports )
    
    emit:
        rmd_report.out[0]
}
