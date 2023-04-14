/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.results_dir = "test/results"

/* load workflows for testing env */
include { TOPDISK }    from './main.nf'

/* declare input channel for testing */
all_zpools = Channel.fromPath( "test/data/zpools.tmp" )

/* declare scripts channel for testing */
scripts_topdisk = Channel.fromPath( "scripts/08_top3disks.sh" )

workflow {
  TOPDISK ( all_zpools, scripts_topdisk )
}