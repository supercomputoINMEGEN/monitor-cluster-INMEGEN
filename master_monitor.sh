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
# crontab -e
# */15 * * * * /home/itadmin/monitor-cluster-INMEGEN/master_monitor.sh

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

# Se ejecuta el visualizador de nodos en R
Rscript "$monitor_path/scripts/05_nodos_online.R" \
  "$monitor_path/logs/nodos_online.log.gz" \
  "$monitor_path/logs/imagen_nodos_online.rds"

# se ejectua el ejecutador de scripts por ssh, y el primer argumento es la lista de servidores a revisar, Y  el segundo argumento es el script que vas a mandar por ssh
bash "$monitor_path/scripts/ssh-executer.sh" \
  "$monitor_path/conexioninfo/serverlist.tsv" \
  "$monitor_path/scripts/06_slot_availability.sh" \
| gzip -9 >> "$logdir_path/disponibilidad_en_condor.log.gz"

# Se ejecuta el visualizador de nodos en R
Rscript "$monitor_path/scripts/07_disponibilidad_plot.R" \
  "$monitor_path/logs/disponibilidad_en_condor.log.gz" \
  "$monitor_path/logs/imagen_disponibilidad.rds"

# se ejectua el ejecutador de scripts por ssh, y el primer argumento es la lista de servidores a revisar, Y  el segundo argumento es el script que va a recuperar el uso de recursos en general
bash "$monitor_path/scripts/ssh-executer.sh" \
  "$monitor_path/conexioninfo/serverlist.tsv" \
  "$monitor_path/scripts/08_general_resources.sh" \
| gzip -9 >> "$logdir_path/recursos_por_nodo.log.gz"

# Se ejecuta el visualizador de recursos en R
Rscript "$monitor_path/scripts/09_resources_heatmap.R" \
  "$monitor_path/logs/recursos_por_nodo.log.gz" \
  "$monitor_path/logs/imagen_recursos_libres.rds"

# Se ejecuta el render de Rmarkdown, el primer arg es la ruta al script.Rmd y el segundo arg es el dataset que lee ese rmd
Rscript "$monitor_path/scripts/00.runthemd.R" \
  "$monitor_path/scripts/10_R1_reporte_uso_inadecuado_nodos.Rmd" \
  "$monitor_path/logs/procesos_por_usuario_online.log.gz"

# re-touch the restart token to update the shiny app
touch "$monitor_path/restart.txt"
