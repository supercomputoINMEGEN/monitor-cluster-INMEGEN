/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir = "test/results"

/* load workflows for testing env */
include { ANALYZER }    from './main.nf'

/* declare input channel for testing */
all_groups= Channel.fromPath( "test/data/allgroups.tmp" )

/* declare scripts channel for testing */
scripts_analyzer = Channel.fromPath( "scripts/A_analyze.R" )

workflow {
  ANALYZER ( all_groups, scripts_analyzer )
}
