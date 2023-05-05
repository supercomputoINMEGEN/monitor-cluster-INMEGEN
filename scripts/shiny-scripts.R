# by iaguilaror@gmail.com
# May 4th 2023
# This script must be sourced to the main app.R to enable dynami plots

### get the subtitle and caption for the plots ----
# it is read from the nodos online test tsv
the_subtitle <- vroom( file = "logs/online_test.tsv" ) %>% 
  pull( the_subtitle ) %>% 
  unique( )

the_caption <- vroom( file = "logs/online_test.tsv" ) %>% 
  pull( the_caption ) %>% 
  unique( )

### ONLINE NODES PLOT ----
online_test.f <- function( the_file ){
  
  online_test <- vroom( file = the_file )
  
  online_test.p <- ggplot( data = online_test,
                           mapping = aes( y = registered_name ) ) + 
    geom_point( mapping = aes( x = 1,
                               fill = value,
                               shape = value ),
                color = "black",
                size = 6 ) +
    scale_fill_manual( values = c("ONLINE" = "limegreen",
                                  "OFFLINE" = "tomato") ) +
    scale_shape_manual( values = c("ONLINE" = 24,
                                   "OFFLINE" = 25 ) ) +
    labs( title = "Estado de los nodos de computo",
          subtitle = the_subtitle,
          caption = the_caption ) +
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
  
  # return the plot
  return( online_test.p )
}
