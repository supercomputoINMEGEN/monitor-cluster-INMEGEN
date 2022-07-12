#!/bin/bash

# INSTRUCCIONES:

# 1. Asegurate de que son ejecutables (chmod a+x) los siguientes scripts:
# ./master_monitor.sh
# scripts/01_pinger_local.sh
# scripts/02_number_of_processes.sh

# 2. llene las variables monitor_path, logdir_path y hours de acuerdo al equipo donde sera instalado este monitor, y la periodicidad del muestreo
monitor_path="/home/itadmin/Ongoin_projects/monitor-cluter-INMEGEN"
logdir_path="$monitor_path/logs"

# 3. luego agregue este script en el crontab. Puede seguir este tutorial: https://linuxhint.com/schedule_crontab_job_every_hour/
# Ejemplo de linea para el crontab
# sudo crontab -e
# 0 * * * * /home/itadmin/Ongoin_projects/monitor-cluter-INMEGEN/master_monitor.sh

#cada cuantas horas se tomara la medicion?
hours=1

mkdir -p "$logdir_path"

bash "$monitor_path/scripts/01_pinger_local.sh" "$monitor_path/conexioninfo/serverlist.tsv" \
| gzip -9 >> "$logdir_path/nodos_online.log.gz"

bash "$monitor_path/scripts/02_number_of_processes.sh" \
| gzip -9 >> "$logdir_path/procesos_por_usuario_online.log.gz"

bash "$monitor_path/scripts/03_condor_usage_logs.sh" \
| gzip -9 >> "$logdir_path/procesos_en_condor.log.gz"

bash "$monitor_path/scripts/04_user_connections_logs.sh" \
| gzip -9 > "$logdir_path/conexiones_activas.log.gz"
