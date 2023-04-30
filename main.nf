#!/usr/bin/env nextflow

/*================================================================
The AGUILAR LAB presents...
  The INMEGEN cluster monitor pipeline
- A tool to gather usage info on supercomputing systems at INMEGEN
==================================================================
Version: 0.0.1
Project repository: TBA
==================================================================
Authors:
- IT Design
 Israel Aguilar-Ordonez (iaguilaror@gmail.com)
- IT Development
 Israel Aguilar-Ordonez (iaguilaror@gmail.com)
- Nextflow Port
 Israel Aguilar-Ordonez (iaguilaror@gmail.com)

=============================
Pipeline Processes In Brief:
.
Pre-processing:

Core-processing:
_001_validate-sshkey-connection
_002_number-processes
_003_oldest-connection
_004_server-load
_005_memory-load
_006_diskroot
_007_zpools
_008_top3disks
_009_maxtemp
_010_getusers
_011_getgroups

Pos-processing
A_analyzeR

ENDING

================================================================*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PREPARE PARAMS DOCUMENTATION AND FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*//////////////////////////////
  Define pipeline version
  If you bump the number, remember to bump it in the header description at the begining of this script too
*/
params.ver = "0.0.1"

/*//////////////////////////////
  Define pipeline Name
  This will be used as a name to include in the results and intermediates directory names
*/
params.pipeline_name = "cluster_monitor"

/*//////////////////////////////
  Define the Nextflow version under which this pipeline was developed or successfuly tested
  Updated by iaguilar at JAN 2023
*/
params.nextflow_required_version = '22.10.4'

/*
  Initiate default values for parameters
  to avoid "WARN: Access to undefined parameter" messages
*/
params.help     =   false   //default is false to not trigger help message automatically at every run
params.version  =	false   //default is false to not trigger version message automatically at every run

params.connexion_info  =	false	//if no inputh path is provided, value is false to provoke the error during the parameter validation block
params.sshkey          =    false	//if no inputh path is provided, value is false to provoke the error during the parameter validation block
params.timestamp       =    false    //if no inputh path is provided, value is false to provoke the error during the parameter validation block

/* read the module with the param init and check */
include { } from './modules/doc_and_param_check.nf'

/* load functions for testing env */
include { get_fullParent }  from './modules/useful_functions.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     INPUT PARAMETER VALIDATION BLOCK
  TODO (iaguilar) check the extension of input queries; see getExtension() at https://www.nextflow.io/docs/latest/script.html#check-file-attributes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*
Output directory definition
Default value to create directory is the parent dir of --input_dir
*/
params.output_dir = get_fullParent( params.connexion_info )

/*
  Results and Intermediate directory definition
  They are always relative to the base Output Directory
  and they always include the pipeline name in the variable (pipeline_name) defined by this Script
  This directories will be automatically created by the pipeline to store files during the run
*/

params.results_dir =        "${params.output_dir}/${params.pipeline_name}-results/"
params.intermediates_dir =  "${params.output_dir}/${params.pipeline_name}-intermediate/"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/* load workflows */
include { VALIDATE_SSHKEY }   from  './modules/01-validate-sshkey-connection'
include { NUMBER_PROCESSES }  from  './modules/02-number-processes'
include { OLDEST_CONNECTION } from  './modules/03-oldest-connection'
include { LOAD_AVG }          from  './modules/04-server-load'
include { MEMLOAD }           from  './modules/05-memory-load'
include { DISKROOT }          from  './modules/06-diskroot'
include { ZPOOLS }            from  './modules/07-zpools'
include { TOPDISK }           from  './modules/08-top3disks'
include { MAXTEMP }           from  './modules/09-maxtemp'
include { GETUSERS }          from  './modules/10-getusers'
include { GETGROUPS }         from  './modules/11-getgroups'
include { ANALYZER }          from  './modules/A-analyzeR'
include { RECORDCONFIG }      from  './modules/Z-recordconfigs'

/* load scripts to send to workdirs */
/* declare scripts channel from modules */

scripts_number_processes  = Channel.fromPath( "./scripts/02_number_of_processes.sh" )
scripts_oldest_connection = Channel.fromPath( "./scripts/03_user_connections_logs.sh" )
scripts_load_avg          = Channel.fromPath( "./scripts/04_server_load.sh" )
scripts_memload           = Channel.fromPath( "./scripts/05_memload.sh" )
scripts_diskroot          = Channel.fromPath( "./scripts/06_diskroot.sh" )
scripts_zpools            = Channel.fromPath( "./scripts/07_zpool_status.sh" )
scripts_topdisk           = Channel.fromPath( "./scripts/08_top3disks.sh" )
scripts_maxtemp           = Channel.fromPath( "./scripts/09_maxtemp.sh" )
scripts_getusers          = Channel.fromPath( "./scripts/10_getusers.sh" )
scripts_getgroups         = Channel.fromPath( "./scripts/11_getgroups.sh" )
scripts_analyzer          = Channel.fromPath( "./scripts/A_analyze.R" )

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
// See: https://github.com/nf-core/rnaseq/issues/619
//

workflow {

  all_validations = VALIDATE_SSHKEY ()
  all_processes = NUMBER_PROCESSES ( all_validations, scripts_number_processes )
  all_oldest = OLDEST_CONNECTION ( all_processes, scripts_oldest_connection )
  all_avg = LOAD_AVG ( all_oldest, scripts_load_avg )
  all_mem = MEMLOAD ( all_avg, scripts_memload )
  all_diskroot = DISKROOT ( all_mem, scripts_diskroot )
  all_zpools = ZPOOLS ( all_diskroot, scripts_zpools )
  all_topdisk = TOPDISK ( all_zpools, scripts_topdisk )
  all_temp = MAXTEMP ( all_topdisk, scripts_maxtemp )
  all_users = GETUSERS ( all_temp, scripts_getusers )
  all_groups = GETGROUPS ( all_users, scripts_getgroups )
  ANALYZER ( all_groups, scripts_analyzer )


  /* declare input channel for recording configs */
  nfconfig = Channel.fromPath( "nextflow.config" )
  RECORDCONFIG( nfconfig )

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/