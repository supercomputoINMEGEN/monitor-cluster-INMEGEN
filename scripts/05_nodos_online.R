# load libs
library("pacman")

p_load( "vroom",
        "dplyr",
        "ggplot2",
        "lubridate" )

#read args from command line
args <- commandArgs( trailingOnly = TRUE )

# pass args to objects
ifile <- args[1]
ofile <- args[2]

# read data
nodos <- read.table( file = ifile,
                     sep = "\t",
                     header = FALSE ) %>% 
  rename( dia = 1,
          fecha = 2,
          hora = 3,
          nodo = 4,
          ip = 5,
          estado = 6 ) %>% 
  mutate( fecha2 = dmy(fecha),
          hora2 = hm(hora) ) %>% 
  group_by( nodo ) %>% 
  arrange( nodo, fecha2, hora2 ) %>% 
  slice( n( ) ) %>%    # extract the last line after arrange
  ungroup( )

# plot
panel_nodo <- ggplot( data = nodos,
                      mapping = aes( x = 1,
                                     y = nodo,
                                     fill = estado,
                                     label = estado ) ) + 
  geom_tile( color = "black",
             size = 1 ) +
  geom_text( color = "white" ) +
  scale_fill_manual( values = c("En_Linea" = "limegreen",
                                "FALLA_NO_da_ping" = "tomato") ) +
  labs( title = "Estado de los nodos de computo",
        subtitle = paste("Ultima revision",
                         unique( nodos$dia),
                         unique( nodos$fecha ),
                         unique( nodos$hora ) ),
        caption = "Jefatura de Supercomputo - INMEGEN") +
  theme_void( ) +
  theme( axis.text.y = element_text( face = "bold",
                                     hjust = 1,
                                     size = 15 ),
         legend.position = "none",
         plot.title = element_text( hjust = 0.5 ),
         plot.subtitle = element_text( hjust = 0.5,
                                       size = 7 ) )

# save plot for easy loading
saveRDS( panel_nodo,
         file = ofile )
