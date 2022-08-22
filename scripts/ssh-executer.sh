#!/bin/bash

# read server + ip file from args
conexionfile=$1

# definir el script que se enviara a cada nodo
elscript=$2

while read la_linea
do
  ## set routes
	la_ip=$(echo "$la_linea" | cut -f1)
	el_hostname=$(echo "$la_linea" | cut -f2)
	el_puerto=$(echo "$la_linea" | cut -f4)
  # Usaremos ConnectTimeout 10 para darle 10 segundos al comando para establecer conexion
  ssh \
		-o ConnectTimeout=10 \
    -p $el_puerto itadmin@"$la_ip" \
    'bash -s' < $elscript "$timestamp" ||
	echo "#FALLA $el_hostname"
  #
done < <( grep -v "#" $conexionfile )
