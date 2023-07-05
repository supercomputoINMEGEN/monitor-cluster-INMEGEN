/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir = "test/results"

/* load workflows for testing env */
include { MAXTEMP }    from './main.nf'

/* declare input channel for testing */
all_topdisk = Channel.fromPath( "test/data/topdisk.tmp" )

/* declare scripts channel for testing */
scripts_maxtemp = Channel.fromPath( "scripts/09_maxtemp.sh" )

workflow {
  MAXTEMP ( all_topdisk, scripts_maxtemp )
}