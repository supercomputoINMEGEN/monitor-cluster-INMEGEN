/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir = "test/results"

/* load workflows for testing env */
include { DISKROOT }    from './main.nf'

/* declare input channel for testing */
all_mem = Channel.fromPath( "test/data/memload.tmp" )

/* declare scripts channel for testing */
scripts_diskroot = Channel.fromPath( "scripts/06_diskroot.sh" )

workflow {
  DISKROOT ( all_mem, scripts_diskroot )
}