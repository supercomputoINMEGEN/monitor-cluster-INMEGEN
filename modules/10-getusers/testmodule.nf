/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir = "test/results"

/* load workflows for testing env */
include { GETUSERS }    from './main.nf'

/* declare input channel for testing */
all_temp = Channel.fromPath( "test/data/maxtemp.tmp" )

/* declare scripts channel for testing */
scripts_getusers = Channel.fromPath( "scripts/10_getusers.sh" )

workflow {
  GETUSERS ( all_temp, scripts_getusers )
}
