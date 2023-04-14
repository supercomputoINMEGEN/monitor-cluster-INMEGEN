/* Inititate DSL2 */
nextflow.enable.dsl=2

// /* Define the main processes */
process split_servers {

  input:
    path  CONEXIONS

  output:
    path "server_*", emit: split_servers_results

  script:
  """
  grep -v "^#" \
    $CONEXIONS \
  |  split -l 1 --numeric-suffixes - server_
  """

}

process validate_sshkey {

  input:
    path  SERVER

  output:
    path "*.sshkey_validation.tmp", emit: validate_sshkey_results

  script:
  """
    conn=\$(cat $SERVER)
    subsystem="\$(echo \$conn | cut -d' ' -f1)"
    registered_hostname="\$(echo \$conn | cut -d' ' -f2)"
    ip="\$(echo \$conn | cut -d' ' -f3)"
    port="\$(echo \$conn | cut -d' ' -f4)"
    user="\$(echo \$conn | cut -d' ' -f5)"
    test_result=\$(ssh \
      -o ConnectTimeout=10 \
      -i ${params.sshkey} \
      -p \$port \$user@\$ip \
      -t 'echo sshkey_OK' || echo sshkey_FAIL)
    echo "\$conn \$test_result" > $SERVER".sshkey_validation.tmp"
  """
}

process join_validations {

  publishDir "${params.results_dir}/01-validate-sshkey-connection/", mode:"copyNoFollow"

  input:
    path  VALIDATIONS

  output:
    path "all_validations.tmp", emit: join_validations_results
  
  script:
  """
    cat * > all_validations.tmp
  """

}

/* name a flow for easy import */
workflow VALIDATE_SSHKEY {

  main:

  connexion_ch = Channel.fromPath (params.connexion_info )
  
  servers_ch = split_servers( connexion_ch ) | flatten

  validation_ch = validate_sshkey( servers_ch ).toList( )
  
  join_validations( validation_ch )

  emit:
    join_validations.out[0]
  
}
