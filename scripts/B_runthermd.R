# This script exists as an interface to pass parameters to RMD in an ordered manner
pacman::p_load( "rmarkdown" )

## Read args from command line
args = commandArgs( trailingOnly = TRUE )

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- "scripts/B_R1_reporte_uso_inadecuado_nodos.Rmd"
# args[2] <- "_inactividad_nodos"

## Passing args to named objects
rmd_file <- args[1]
ofile_sufix <- args[2]

## Create the a custom output name for the rmd
output_pdf <- paste0( Sys.Date(), ofile_sufix, ".pdf" )

# define the localdir to avoid errors during rendering
localdir <- getwd( )

# call the renderizer
rmarkdown::render(  input = rmd_file,
                    output_file = output_pdf,
                    output_dir = localdir, # if we dont fix the wd here, knit will fail when NF tries to execute it from a different workdir
                    intermediates_dir = localdir, # if we dont fix the wd here, knit will fail when NF tries to execute it from a different workdir
                    knit_root_dir = localdir ) # if we dont fix the wd here, knit will fail when NF tries to execute it from a different workdir
