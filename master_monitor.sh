#!/bin/bash

# INSTRUCCIONES:

# Pre-0. Instala R (puedes seguir este tuto https://linuxize.com/post/how-to-install-r-on-ubuntu-20-04/)
#	e instala los siguientes paquetes:
# vroom, dplyr, ggplot2, stringr, lubridate

# 0. Asegurate de configurar la conexion por llave ssh entre el monitor donde esta instalado este scripts
#     y los hosts en conexioninfo/serverlist.tsv
#     Puedes seguir este tutorial: https://linuxhint.com/generate-ssh-key-ubuntu/
#     Si tienes problemas con que los hosts acepten la conexion pr llave ssh, revisa esta respuesta: https://unix.stackexchange.com/questions/36540/why-am-i-still-getting-a-password-prompt-with-ssh-with-public-key-authentication

# 0.5. Prueba tu conexion con ssh-key con el siguiente comando
#      ssh -p 5263 itadmin@cluster.inmegen.gob.mx 'echo conectado a $(hostname)'
#      y deberia responder algo como:     conectado a corellia

# 1. Asegurate de que son ejecutables (chmod a+x) los siguientes scripts:
# ./master_monitor.sh
# scripts/01_pinger_local.sh
# scripts/02_number_of_processes.sh
# scripts/...

# 2. Prueba el monitor ejecuando el script tester con:
#	bash teste.sh
# (si hay alguna carpeta con logs previos en ./logs, te va a prueguntar si lo quieres borrar)

# 3. luego agregue este script en el crontab. Puede seguir este tutorial: https://linuxhint.com/schedule_crontab_job_every_hour/
# Ejemplo de linea para el crontab
# sudo crontab -e
# 0 * * * * /home/itadmin/Ongoin_projects/monitor-cluter-INMEGEN/master_monitor.sh

# automatically get the dir from this master script; answer taken from: https://stackoverflow.com/questions/3349105/how-can-i-set-the-current-working-directory-to-the-directory-of-the-script-in-ba
monitor_path="$(dirname ${BASH_SOURCE[0]})"
logdir_path="$monitor_path/logs"

# uncomment to test monitor path assign
# echo $monitor_path

# create el results dir
mkdir -p "$logdir_path"

# mark timestamp
export timestamp=$(date +"%A_%d-%m-%Y_%R")

# se ejectua el pinger, y el primer argumento es la lista de servidores a revisar, Y  el ultimo argumento es el tiempo que se esta midiendo
bash "$monitor_path/scripts/01_pinger_local.sh" \
  "$monitor_path/conexioninfo/serverlist.tsv" \
| gzip -9 >> "$logdir_path/nodos_online.log.gz"

# se ejectua el ejecutador de scripts por ssh, y el primer argumento es la lista de servidores a revisar, Y  el segundo argumento es el script que vas a mandar por ssh, , Y  el ultimo argumento es el tiempo que se esta midiendo
bash "$monitor_path/scripts/ssh-executer.sh" \
  "$monitor_path/conexioninfo/serverlist.tsv" \
  "$monitor_path/scripts/02_number_of_processes.sh" \
| gzip -9 >> "$logdir_path/procesos_por_usuario_online.log.gz"

# se ejectua el ejecutador de scripts por ssh, y el primer argumento es la lista de servidores a revisar, Y  el segundo argumento es el script que vas a mandar por ssh
bash "$monitor_path/scripts/ssh-executer.sh" \
  "$monitor_path/conexioninfo/serverlist.tsv" \
  "$monitor_path/scripts/03_condor_usage_logs.sh" \
| gzip -9 >> "$logdir_path/procesos_en_condor.log.gz"

# se ejectua el ejecutador de scripts por ssh, y el primer argumento es la lista de servidores a revisar, Y  el segundo argumento es el script que vas a mandar por ssh
bash "$monitor_path/scripts/ssh-executer.sh" \
  "$monitor_path/conexioninfo/serverlist.tsv" \
  "$monitor_path/scripts/04_user_connections_logs.sh" \
| gzip -9 > "$logdir_path/conexiones_activas.log.gz"
