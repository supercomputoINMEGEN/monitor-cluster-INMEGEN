/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process rmd_report_1 {

    publishDir "${params.results_dir}/B-rmdreports/", mode:"copyNoFollow"

    input:
        path LOGS
        path SCRIPTS

    output:
        path "*.pdf"

    script:
    """
    Rscript --vanilla B_runthermd.R \
        B_R1_reporte_uso_inadecuado_nodos.Rmd \
        "_uso_inadecuado_nodos"
    """

}

process rmd_report_2 {

    publishDir "${params.results_dir}/B-rmdreports/", mode:"copyNoFollow"

    input:
        path LOGS
        path SCRIPTS

    output:
        path "*.pdf"

    script:
    """
    Rscript --vanilla B_runthermd.R \
        B_R2_reporte_inactividad_nodos.Rmd \
        "_inactividad_nodos"
    """

}

process rmd_report_3 {

    publishDir "${params.results_dir}/B-rmdreports/", mode:"copyNoFollow"

    input:
        path LOGS
        path SCRIPTS

    output:
        path "*.pdf"

    script:
    """
    Rscript --vanilla B_runthermd.R \
        B_R3_reporte_heatmap_users_y_groups.Rmd \
        "_reporte_heatmap_users_y_groups"
    """

}

/* name a flow for easy import */
workflow RMD_REPORT {

    take:
        all_logsgz
        scripts_rmd_reports

    main:        
        rmd_report_1( all_logsgz, scripts_rmd_reports )
        rmd_report_2( all_logsgz, scripts_rmd_reports )
        rmd_report_3( all_logsgz, scripts_rmd_reports )

}
