/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir = "test/results"

/* load workflows for testing env */
include { RMD_REPORT }    from './main.nf'

/* declare input channel for testing */
all_logsgz = Channel.fromPath( "test/data/*.gz" ).toList()

/* declare scripts channel for testing */
scripts_rmd_reports = Channel.fromPath( "scripts/B_*" ).toList()

workflow {
  RMD_REPORT ( all_logsgz, scripts_rmd_reports )
}
