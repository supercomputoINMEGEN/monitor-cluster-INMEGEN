/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.results_dir = "test/results"

/* load workflows for testing env */
include { ZPOOLS }    from './main.nf'

/* declare input channel for testing */
all_diskroot = Channel.fromPath( "test/data/diskroot.tmp" )

/* declare scripts channel for testing */
scripts_zpools = Channel.fromPath( "scripts/07_zpool_status.sh" )

workflow {
  ZPOOLS ( all_diskroot, scripts_zpools )
}