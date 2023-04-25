/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir = "test/results"

/* load workflows for testing env */
include { LOAD_AVG }    from './main.nf'

/* declare input channel for testing */
all_oldest = Channel.fromPath( "test/data/oldest_connection.tmp" )

/* declare scripts channel for testing */
scripts_load_avg = Channel.fromPath( "scripts/04_server_load.sh" )

workflow {
  LOAD_AVG ( all_oldest, scripts_load_avg )
}