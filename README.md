# monitor-cluter-INMEGEN
Proyecto de UI shinny para monitorear el estado y uso de cluster inmegen

# Flow
test-ssh -> local_pinger.sh -> number_of_processe -> condor_usage? -> user_connections -> online_nodes -> slot_availability (condor?) -> 7 create disponibility plot -> 08 general resources -> 9 heatmap resources -> 10 RMD uso inadecuado -> 11 RMD inactividad de nodos

# Contenidos

* conexioninfo/  
incluye el archivo serverlist.tsv, que registra:  
IP  nombre_coloquial_del_server responsable puerto para conexion

''''
10.0.15.5	central-15	lgomez	22
''''

* scripts/  
incluye varios scripts para realizar el monitoreo remoto

* WWW/  
incluye PDFS para mostrar en la UI

# Configuracion del monitor

1 Verificar que se puede hacer SSH con ssh-key a cada nodo en conexioninfo/serverlist.tsv

2 clonar este repo en tu directorio shiny. p.ej. /srv/shiny-server/myapps/monitor-cluster-INMEGEN

''''
cd /srv/shiny-server
cd myapps/
git clone git@github.com:Iaguilaror/monitor-cluster-INMEGEN.git
''''

3 configurar el nextflow.config

4 ejecutar bash runtest.sh para validar que todo funciona

5 configurar un cronjob, por ejemplo:
# m h  dom mon dow   command
*/15 * * * * /srv/shiny-server/myapps/monitor-cluster-INMEGEN/launcher.sh
