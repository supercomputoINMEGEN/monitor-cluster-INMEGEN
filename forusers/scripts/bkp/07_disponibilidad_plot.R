# load libs
library("pacman")

p_load( "vroom",
        "dplyr",
        "ggplot2",
        "tidyr",
        "lubridate",
        "waffle",
        "scales",
        "cowplot" )

#read args from command line
args <- commandArgs( trailingOnly = TRUE )

# pass args to objects
ifile <- args[1] # <- "../logs/disponibilidad_en_condor.log.gz" 
ofile <- args[2]

# read data
slots <- vroom( file = ifile, col_names = FALSE ) %>% 
  rename( timestamp = 1,
          total = 2,
          claimed = 3,
          unclaimed = 4 ) %>% 
  separate( col =  timestamp,
            into = c( "dia", "fecha", "hora" ),
            sep = "_" ) %>% 
  mutate( fecha2 = dmy(fecha),
          hora2 = hm(hora) ) %>% 
  arrange( fecha2, hora2 ) %>% 
  filter( !is.na( fecha2) ) %>%     # eliminate missing dates
  slice( n() )    # extract the last line after arrange

# plot a waffle
waf_data <- c( Ocupados = slots$claimed,
               Libres = slots$unclaimed )

# Gráfico de waffle
waffle <- waffle( waf_data, rows = 8,
                  flip = TRUE,
                  reverse = TRUE,
                  keep = FALSE,
                  # colors = c( "tomato", "limegreen" ),
                  title = "Slots (threads) de Computo") +
  scale_fill_manual( values = c( "Ocupados" = "tomato",
                                 "Libres" = "limegreen" ),
                     limits = rev ) +
  labs( subtitle = paste("Ultima revision",
                         unique( slots$dia),
                         unique( slots$fecha ),
                         unique( slots$hora ) ),
#        caption = "Jefatura de Supercomputo - INMEGEN"
) +
  theme_linedraw(  ) +
  theme( axis.text = element_blank( ),
         axis.ticks = element_blank( ),
         plot.title = element_text( hjust = 0.5, size = 20 ),
         plot.subtitle = element_text( hjust = 0.5, size = 10 ),
         legend.position = "top",
         legend.title = element_blank( ),
         legend.text = element_text( size = 15 ) )

# grafico de barra delgada
percentdata <- slots %>% 
  select( claimed, unclaimed ) %>% 
  pivot_longer( cols = 1:2,
                names_to = "group",
                values_to = "n" ) %>% 
  mutate( percentage = n / sum( n ) )

# prepare percent free
libre <- percentdata %>% 
  filter( group == "unclaimed" ) %>% 
  pull( percentage ) %>% 
  percent( accuracy = 1 )

# plot bars
barra <- ggplot( data = percentdata,
                 mapping = aes( x = 1,
                                y = n,
                                fill = group ) ) +
  geom_col( color = "black" ) +
  # scale_x_continuous( limits = c( 0, 2 ) ) +
  scale_fill_manual( values = c( "claimed" = "gray30",
                                 "unclaimed" = "limegreen" ) ) +
  labs( title = paste( libre, "threads libres" ) ) +
  coord_flip( ) +
  theme_void( ) +
  theme( legend.position = "none",
         plot.title = element_text( hjust = 0.5, size = 20) )

# create a panel
panel_disponible <- plot_grid( rel_heights = c( 0.85, 0.15 ) ,
                               waffle, barra, ncol = 1 )


# save plot for easy loading
saveRDS( panel_disponible,
         file = ofile )
