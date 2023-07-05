/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir =  "test/results"

/* load workflows for testing env */
include { OLDEST_CONNECTION }    from './main.nf'

/* declare input channel for testing */
all_processes = Channel.fromPath( "test/data/processes.tmp" )

/* declare scripts channel for testing */
scripts_oldest_connection = Channel.fromPath( "scripts/03_user_connections_logs.sh" )

workflow {
  OLDEST_CONNECTION ( all_processes, scripts_oldest_connection )
}