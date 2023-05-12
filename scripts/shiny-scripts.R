# by iaguilaror@gmail.com
# May 4th 2023
# This script must be sourced to the main app.R to enable dynami plots

# Parametrize
max_days_for_connection <- 14            # max days to flag an old connection as warning
max_fracc_for_waring_on_top3disk <- 0.5  # mas percentage (as fraction 0.5 = 50%) to mark as warning on disk usage

### get the subtitle and caption for the plots ----

# define the input
online_test_file <- "logs/online_test.tsv"

# check if the log file exists (it exists in shiny run; but for module test runs we use a dummy date)
if ( file.exists( online_test_file )   ) {
  
  # it is read from the nodos online test tsv
  the_subtitle <- vroom( file = "logs/online_test.tsv" ) %>% 
    pull( the_subtitle ) %>% 
    unique( )
  
  the_caption <- vroom( file = "logs/online_test.tsv" ) %>% 
    pull( the_caption ) %>% 
    unique( )
  
} else {  # if file does not exist, we use dummies
  
  the_subtitle <- "Un subtitulo"
  the_caption <- "Un caption"
  
}

# create a function to reorder factors
reorder.f <- function( the_data ) {
  
  # Define server order
  ordered_servers <- the_data %>% 
    select( subsystem, registered_name, registered_and_hostname )
  
  the_data <- the_data %>% 
    mutate( subsystem = factor( subsystem,
                                levels = unique( ordered_servers$subsystem ) ) ) %>% 
    mutate( registered_name = factor( registered_name,
                                      levels = unique( ordered_servers$registered_name ) ) ) %>% 
    mutate( registered_and_hostname = factor( registered_and_hostname,
                                              levels = unique( ordered_servers$registered_and_hostname ) ) )
  
  # return
  the_data
  
}

### ONLINE NODES PLOT ----
online_test.f <- function( the_file ){
  
  online_test <- vroom( file = the_file )
  
  online_test.p <- ggplot( data = reorder.f( online_test ),
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

#### Number of process by user ----
# do plot
number_of_process.f <- function( the_number_of_process, the_percent_process, the_ordered_process ){
  
  number_proc <- vroom( file = the_number_of_process )
  percent_proc <- vroom( file = the_percent_process )
  order_proc <- vroom( file = the_ordered_process )
  
  ggplot( data = reorder.f( number_proc ),
          mapping = aes( x = hostname,
                         y = user,
                         label = value ) ) +
    geom_tile( data = reorder.f( percent_proc ),
               mapping = aes( fill = perc ),
               color = "black",
               alpha = 0.3 ) +
    geom_text( ) +
    scale_y_discrete( limits = order_proc$user ) +
    scale_fill_gradient( low = "white", high = "blue" ) +
    labs( title = "Numero de Procesos por Usuario",
          subtitle = the_subtitle,
          caption = the_caption ) +
    theme_light( ) +
    theme(
      legend.position = "none",
      plot.title = element_text( hjust = 0.5 ),
      plot.subtitle = element_text( hjust = 0.5,
                                    size = 7 ),
      strip.background = element_rect( fill = "white" ),
      strip.text = element_text( color = "black" )  ) +
    facet_wrap( ~ subsystem, ncol = 1, scales = "free_x" )
  
}

## plot oldest connection ----

oldest_connection.f <- function( the_data ){
  
  oldconn <- vroom( file = the_data )
  
  ggplot( data = reorder.f( oldconn ),
          mapping = aes( x = hostname,
                         y = user,
                         label = oldest_conn,
                         fill = fecha_flag ) ) +
    geom_tile( color = "black",
               alpha = 0.3 ) +
    geom_text( ) +
    scale_y_discrete( limits = unique( oldconn$user ) ) +
    scale_fill_manual( values = c( "OK" = "limegreen",
                                   "Warning" = "tomato" )  ) +
    labs( title = "Dias de la Conexion mas Vieja por usuario",
          subtitle = paste0( the_subtitle,
                             "\n", "En rojo las conexiones mas viejas que ",
                             max_days_for_connection, " dias" ),
          caption = the_caption ) +
    theme_light( ) +
    theme(
      legend.position = "none",
      plot.title = element_text( hjust = 0.5 ),
      plot.subtitle = element_text( hjust = 0.5,
                                    size = 7 ),
      strip.background = element_rect( fill = "white" ),
      strip.text = element_text( color = "black" )  ) +
    facet_wrap( ~ subsystem, ncol = 1, scales = "free_x" )
  
}

# plot resources
# plot the resources
all_resources.f <- function( the_data ) {
  
  allres <- vroom( file = the_data ) %>% 
    mutate( label = str_replace( string = label,
                                 pattern = "_",
                                 replacement = "\n" ) )
  
  ggplot( data = reorder.f( allres ),
          mapping = aes( x = test,
                         y = registered_and_hostname,
                         fill = perc,
                         label = label ) ) +
    geom_tile( color = "white", alpha = 0.3, size = 3 ) +
    geom_text( ) +
    # scale_y_discrete( limits = unique( ordered_servers$registered_and_hostname ) ) +
    scale_x_discrete( limits = c( "load_avg_1min", "load_mem",
                                  "load_rootdisk", "maxtemp_C" ),
                      labels = c( "CPU threads", "RAM mem",
                                  "/ disk", "temperature " ), position = "top" ) +
    scale_fill_gradient2( low = "green", mid = "yellow",
                          high = "red", midpoint = 0.5, limits = c( 0, 1) ) +
    labs( title = "Recursos Disponibles",
          subtitle = the_subtitle,
          caption = the_caption,
          x = "Recurso",
          y = "nombre registrado( hostname )"  ) +
    theme_light( base_size = 15 ) +
    theme(
      legend.position = "none",
      plot.title = element_text( hjust = 0.5 ),
      plot.subtitle = element_text( hjust = 0.5,
                                    size = 7 ),
      panel.grid = element_blank( ) )
  
}

### plot columns for offending %disk ----
top3disks.f <- function( the_data ){ 
  
  topdisk <- vroom( file = the_data )
  
  ggplot( mapping = aes( x = disk,
                         y = perc ) ) +
    geom_col( data = filter( reorder.f( top3disks), perc < max_fracc_for_waring_on_top3disk ),
              width = 0.1, fill = "gray50" ) +
    geom_col( data = filter( reorder.f( top3disks ), perc >= max_fracc_for_waring_on_top3disk ),
              width = 0.1, fill = "tomato" ) +
    geom_text( data = filter( reorder.f( top3disks ), perc >= max_fracc_for_waring_on_top3disk ),
               mapping = aes( label = disk ),
               angle = 90, nudge_y = 0.1 ) +
    geom_hline( yintercept = max_fracc_for_waring_on_top3disk,
                lty = "dashed",
                color = "tomato" ) +
    scale_y_continuous( limits = c( 0, 1 ),
                        breaks = seq( from = 0, to = 1, by = 0.25 ),
                        labels = percent ) +
    labs( title = "% usado en los Top3 discos por tamano total",
          subtitle = "de cada servidor",
          x = "discos",
          y = "% de disco usado" ) +
    theme_light( base_size = 15 ) +
    theme( axis.text.x =  element_blank( ),
           panel.grid.major.x = element_blank( ),
           strip.background = element_rect( color = "black", fill = "white" ),
           strip.text = element_text( color = "black" ) ) +
    facet_wrap( ~ subsystem, scales = "free_x" )
  
}
