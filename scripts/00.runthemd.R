# This script exists as an interface to pass parameters to RMD in an ordered manner

## Read args from command line
args = commandArgs( trailingOnly = TRUE )

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- "10_R1_reporte_uso_inadecuado_nodos.Rmd" ##  ejem "10_R1_reporte_uso_inadecuado_nodos.Rmd"
# args[2] <- "../logs/procesos_por_usuario_online.log.gz" ##  ejem "../logs/procesos_por_usuario_online.log.gz"

## Passing args to named objects
rmd_file <- args[1]
ifile <- args[2]
output_pdf <- args[3]

# call the renderizer
rmarkdown::render( input = rmd_file, output_file = output_pdf  ) 
