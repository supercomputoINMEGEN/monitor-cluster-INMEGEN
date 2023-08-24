/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir = "test/results"

/* load workflows for testing env */
include { STORCLI }    from './main.nf'

/* declare input channel for testing */
all_groups = Channel.fromPath( "test/data/allgroups.tmp" )

/* declare scripts channel for testing */
scripts_storcli = Channel.fromPath( "scripts/12_checkstorcli.sh" )

workflow {
  STORCLI ( all_groups, scripts_storcli )
}
