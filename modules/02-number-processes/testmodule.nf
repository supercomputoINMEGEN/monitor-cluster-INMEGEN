/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.results_dir = "test/results"

/* load workflows for testing env */
include { NUMBER_PROCESSES }    from './main.nf'

/* declare input channel for testing */
all_validations = Channel.fromPath( "test/data/all_validations.tmp" )

/* declare scripts channel for testing */
scripts_number_processes = Channel.fromPath( "scripts/02_number_of_processes.sh" )

workflow {
  NUMBER_PROCESSES ( all_validations, scripts_number_processes )
}