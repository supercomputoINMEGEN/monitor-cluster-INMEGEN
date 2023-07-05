#!/bin/bash

# read server + ip file from args
conexionfile=$1

# echo " [DEBUG] Se ejecuta la prueba ping -i 5 -c 1 la_ip para las siguientes ips"
# echo " [DEBUG] cada ping esperará aprox. 15 segundos la respuesta de la_ip"
# echo " [DEBUG] Se hace la prueba desde la red: $la_red"
# echo "==[RESULTADOS]=="
while read la_linea
do
	## set routes
	la_ip=$(echo "$la_linea" | cut -f1)
	el_hostname=$(echo "$la_linea" | cut -f2)
	el_responsable=$(echo "$la_linea" | cut -f3)
	# echo "[REVISANDO la ip] $la_ip"
	## run test
	PRUEBA=$(ping -i 1 -c 1 $la_ip > /dev/null \
	&& echo "En_Linea" \
	|| echo "FALLA_NO_da_ping" )
	### Send message
	echo "$timestamp" "$el_hostname $la_ip" "$PRUEBA" | tr " " "\t"
done < <( grep -v "#" $conexionfile )
