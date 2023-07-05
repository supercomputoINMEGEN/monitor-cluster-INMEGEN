/* Define the help message as a function to call when needed *//////////////////////////////
def the_help() {
	log.info"""
  /*================================================================
  The AGUILAR LAB presents...
  The INMEGEN cluster monitor pipeline
- A tool to gather usage info on supercomputing systems at INMEGEN
  v${params.ver}
  ==========================================
	Usage:
  nextflow run main.nf --input_dir <connexion_info> <sshkey> <timestamp> [--output_dir path to results ]
	  --connexion_info		<- To-do;
					To-do;
					To-do;
      --sshkey          <- To-do;
      --timestamp       <- To-do;
	  --output_dir		<- directory where results, intermediate and log files will bestored;
					default: same dir where --query_fasta resides
	  -resume	   <- Use cached results if the executed project has been run before;
				default: not activated
				This native NF option checks if anything has changed from a previous pipeline execution.
				Then, it resumes the run from the last successful stage.
				i.e. If for some reason your previous run got interrupted,
				running the -resume option will take it from the last successful pipeline stage
				instead of starting over
				Read more here: https://www.nextflow.io/docs/latest/getstarted.html#getstart-resume
	  --help           <- Shows Pipeline Information
	  --version        <- Show Pipeline version
	""".stripIndent()
}

/*//////////////////////////////
  If the user inputs the --help flag
  print the help message and exit pipeline
*/
if (params.help){
	the_help()
	exit 0
}

/*//////////////////////////////
  If the user inputs the --version flag
  print the pipeline version
*/
if (params.version){
	println "Pipeline v${params.ver}"
	exit 0
}

/*
  Try Catch to verify compatible Nextflow version
  If user Nextflow version is lower than the required version pipeline will continue
  but a message is printed to tell the user maybe it's a good idea to update her/his Nextflow
*/
try {
	if( ! nextflow.version.matches(">= $params.nextflow_required_version") ){
		throw GroovyException('Your Nextflow version is older than Pipeline required version')
	}
} catch (all) {
	log.error "-----\n" +
			"  This pipeline requires Nextflow version: $params.nextflow_required_version \n" +
            "  But you are running version: $workflow.nextflow.version \n" +
			"  The pipeline will continue but some things may not work as intended\n" +
			"  You may want to run `nextflow self-update` to update Nextflow\n" +
			"============================================================"
}

/* Check if inputs provided
    if they were not provided, they keep the 'false' value assigned in the parameter initiation block above and this test fails
*/
if ( !params.connexion_info ) {
  log.error " Please provide the following params: --connexion_info \n\n" +
  " For more information, execute: nextflow run main.nf --help"
  exit 1
}
