/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.results_dir = "test/results"

/* load workflows for testing env */
include { GETGROUPS }    from './main.nf'

/* declare input channel for testing */
all_users = Channel.fromPath( "test/data/allusers.tmp" )

/* declare scripts channel for testing */
scripts_getgroups = Channel.fromPath( "scripts/11_getgroups.sh" )

workflow {
  GETGROUPS ( all_users, scripts_getgroups )
}
