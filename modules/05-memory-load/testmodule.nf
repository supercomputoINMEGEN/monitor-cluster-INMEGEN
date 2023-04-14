/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.results_dir = "test/results"

/* load workflows for testing env */
include { MEMLOAD }    from './main.nf'

/* declare input channel for testing */
all_avg = Channel.fromPath( "test/data/load_avg.tmp" )

/* declare scripts channel for testing */
scripts_memload = Channel.fromPath( "scripts/05_memload.sh" )

workflow {
  MEMLOAD ( all_avg, scripts_memload )
}