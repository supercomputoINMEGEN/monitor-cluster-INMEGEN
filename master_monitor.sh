#!/bin/bash


# INSTRUCCIONES:
# llene las variables monitor_path, logdir_path y hours de acuerdo al equipo donde sera instalado este monitor, y la periodicidad del muestreo
# luego agregue este script en el crontab. Puede seguir este tutorial: https://linuxhint.com/schedule_crontab_job_every_hour/
monitor_path="/home/itadmin/Ongoin_projects/monitor-cluter-INMEGEN"
logdir_path="$monitor_path/logs"

#cada cuantas horas se tomara la medicion?
hours=1

mkdir -p "$logdir_path"

bash "$monitor_path/scripts/01_pinger_local.sh" "$monitor_path/conexioninfo/serverlist.tsv" | gzip -9 > "$logdir_path/nodos_online.log.gz"
