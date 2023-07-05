# load libs
library("pacman")

p_load( "vroom",
        "dplyr",
        "ggplot2",
        "tidyr",
        "lubridate" )

#read args from command line
args <- commandArgs( trailingOnly = TRUE )

# pass args to objects
ifile <- args[1] # <- "../logs/nodos_online.log.gz" 
ofile <- args[2]
serverlist <- args[3] # <- "../configs/server_list.tsv"

# read server list
server_dictionary <- vroom( file = serverlist,
                            comment = "#", col_names = FALSE ) %>% 
  rename( nodo = 1,
          subsystem = 2 )

# get the order of subsystem
subsystems_ordered <- server_dictionary$subsystem %>% unique( )

# read data
nodos <- read.table( file = ifile,
                     sep = "\t",
                     header = FALSE ) %>% 
  rename( timestamp = 1,
          nodo = 2,
          ip = 3,
          estado = 4 ) %>% 
  separate( col =  timestamp,
            into = c( "dia", "fecha", "hora" ),
            sep = "_" ) %>% 
  mutate( fecha2 = dmy(fecha),
          hora2 = hm(hora) ) %>% 
  group_by( nodo ) %>% 
  arrange( nodo, fecha2, hora2 ) %>% 
  slice( n( ) ) %>%    # extract the last line after arrange
  ungroup( ) %>% 
  left_join( x = .,
             y = server_dictionary,
             by = "nodo" ) %>% 
  mutate( nodo = factor( nodo,
                         levels = rev( server_dictionary$nodo ) ) ) %>% 
  mutate( subsystem = factor( subsystem,
                              levels = (subsystems_ordered) ) )

# plot
panel_nodo <- ggplot( data = nodos,
        mapping = aes( y = nodo ) ) + 
  geom_point( mapping = aes( x = 1,
                             fill = estado,
                             shape = estado ),
              color = "black",
              size = 6 ) +
  # geom_text( mapping = aes( x = 1.5,
  #                           label = estado ),
  #            size = 6,
  #            hjust = 0,
  #            color = "black" ) +
  scale_fill_manual( values = c("En_Linea" = "limegreen",
                                "FALLA_NO_da_ping" = "tomato") ) +
  scale_shape_manual( values = c("En_Linea" = 24,
                                "FALLA_NO_da_ping" = 25 ) ) +
  labs( title = "Estado de los nodos de computo",
        subtitle = paste("Ultima revision",
                         unique( nodos$dia),
                         unique( nodos$fecha ),
                         unique( nodos$hora ) ),
        caption = "Jefatura de Supercomputo - INMEGEN") +
  # scale_x_continuous( limits = c( 0.5, 4 ) ) +
  theme_void( ) +
  theme( axis.text.y = element_text( face = "bold",
                                     hjust = 1,
                                     size = 15 ),
         legend.position = "none",
         plot.title = element_text( hjust = 0.5 ),
         plot.subtitle = element_text( hjust = 0.5,
                                       size = 7 ),
         panel.background = element_rect( color = "black" ) ) +
  facet_wrap( ~ subsystem, ncol = 1, scales = "free_y" )

# save plot for easy loading
saveRDS( panel_nodo,
         file = ofile )
