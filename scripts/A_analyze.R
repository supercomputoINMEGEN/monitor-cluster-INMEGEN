# load libs

#install.packages( "pacman", repos = "http://cran.us.r-project.org" )
library("pacman")

p_load( "vroom",
        "dplyr",
        "ggplot2",
        "tidyr",
        "lubridate",
        "stringr",
        "scales",
        "gdata" )

# Parametrize
max_days_for_connection <- 14            # max days to flag an old connection as warning
max_fracc_for_waring_on_top3disk <- 0.5  # mas percentage (as fraction 0.5 = 50%) to mark as warning on disk usage

#read args from command line
args <- commandArgs( trailingOnly = TRUE )

# pass args to objects
ifile <- args[1]     # <- "test/data/allgroups.tmp" 
timest <- args[2]    # <- "2023-04-15_18:54" 

# split the timestamp
the_date <- unlist(strsplit( x = timest, split = "_" ))[1]
the_time <- unlist(strsplit( x = timest, split = "_" ))[2]

#
the_subtitle <- paste( "Ultima revision",
                       wday( the_date, label = TRUE ),
                       the_date,
                       the_time )

the_caption <- "Jefatura de Supercomputo - INMEGEN"

# read data
the_data <- vroom( file = ifile, col_names = FALSE, show_col_types = FALSE ) %>% 
  rename( subsystem = 1,
          registered_name = 2,
          ip_or_domain = 3,
          port = 4,
          login = 5,
          test = 6,
          user = 7,
          value = 8,
          hostname = 9 ) %>% 
  mutate( date = ymd( the_date ),
          time = hm( the_time ),
          registered_and_hostname = paste0( registered_name, "(", hostname, ")" ) )

# save the data with timestamp
# prepare name for data save
ofile_tsv <- paste(  the_date,
                     str_replace( string = the_time, pattern = ":", replacement = "-"),
                     "monitor-cluster-log.tsv", sep = "_" )

the_data %>% 
  select( -ip_or_domain, -port, -login, -date, -time, -registered_and_hostname  ) %>% 
  write.table( x = ., 
               file = ofile_tsv,
               append = FALSE, quote = FALSE, sep = "\t",
               row.names = FALSE, col.names = TRUE )

system( "gzip -9 *_monitor-cluster-log.tsv" )

# Define server order
ordered_servers <- the_data %>% 
  filter( test == "ssh_connection" ) %>% 
  select( subsystem, registered_name, registered_and_hostname )

# refactor the data to control plot order
the_data <- the_data %>% 
  mutate( subsystem = factor( subsystem,
                              levels = unique( ordered_servers$subsystem ) ) ) %>% 
  mutate( registered_name = factor( registered_name,
                                    levels = unique( ordered_servers$registered_name ) ) ) %>% 
  mutate( registered_and_hostname = factor( registered_and_hostname,
                                            levels = unique( ordered_servers$registered_and_hostname ) ) )

# get uniq test names
the_data$test %>% unique( )

### plot online data ====
online_test <- the_data %>% 
  filter( test == "ssh_connection" ) %>% 
  select( subsystem, registered_name, value, hostname ) %>% 
  mutate( value = ifelse( test = is.na( value ),
                          yes = "OFFLINE", no = value ) )

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

# save plot for easy loading
saveRDS( object = online_test.p,
         file = "online_test.rds" )

### plot number_processes ====
number_of_process <- the_data %>% 
  filter( test == "number_processes" ) %>% 
  select( subsystem, registered_name, user, value, hostname ) %>%
  mutate( value = as.numeric( value ) ) %>% 
  filter( ! is.na( hostname ) )

# calculate totals_by_user
ordered_process <-  number_of_process %>% 
  group_by( user ) %>% 
  summarise( total_proc = sum( value ),
             total_host = n( ) ) %>% 
  arrange( -total_host, -total_proc )

# Calculate percentage of use by hostname, whitout root
percent_process <- number_of_process %>% 
  filter( user != "root" ) %>% 
  group_by( hostname ) %>% 
  mutate( all_process = sum( value ) ) %>% 
  ungroup( ) %>% 
  mutate( perc = value / all_process )

# do plot
number_of_process.p <- ggplot( data = number_of_process,
                               mapping = aes( x = hostname,
                                              y = user,
                                              label = value ) ) +
  geom_tile( data = percent_process,
             mapping = aes( fill = perc ),
             color = "black",
             alpha = 0.3 ) +
  geom_text( ) +
  scale_y_discrete( limits = ordered_process$user ) +
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

# save plot for easy loading
saveRDS( object = number_of_process.p,
         file = "number_of_process.rds" )

### plot Oldest conections ====
oldest_connection <- the_data %>% 
  filter( test == "oldest_connection" ) %>% 
  select( subsystem, registered_name, user, value, hostname ) %>%
  mutate( fecha = dmy( value, quiet = TRUE ) ) %>% 
  filter( ! is.na( hostname ) ) %>% 
  mutate( oldest_conn = interval( fecha, ymd(the_date) ) %/% days(1),   # calculate number of days to the oldest connection
          fecha_flag = ifelse( test = oldest_conn > max_days_for_connection,
                               yes = "Warning",
                               no = "OK") ) %>% 
  select( subsystem, hostname, user, oldest_conn, fecha_flag ) %>% 
  arrange( user, -oldest_conn ) %>% 
  group_by( hostname, user ) %>% 
  slice( 1 ) %>% 
  ungroup( ) %>% 
  arrange( oldest_conn )

#
oldest_connection.p <- ggplot( data = oldest_connection,
                               mapping = aes( x = hostname,
                                              y = user,
                                              label = oldest_conn,
                                              fill = fecha_flag ) ) +
  geom_tile( color = "black",
             alpha = 0.3 ) +
  geom_text( ) +
  scale_y_discrete( limits = unique( oldest_connection$user ) ) +
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

# save plot for easy loading
saveRDS( object = oldest_connection.p,
         file = "oldest_connection.rds" )

### plot Oldest load_avg_1min, load_mem, load_rootdisk, maxtemp_C ====
# calc processor
load_avg_1min <- the_data %>% 
  filter( test == "load_avg_1min" ) %>%
  select( subsystem, test, value, registered_and_hostname ) %>% 
  separate( col = value,
            into = c( "load", "max" ),
            sep = "/" ) %>% 
  mutate( perc = as.numeric( load ) /
            as.numeric( max ) ) %>% 
  mutate( label = paste( "disp:", as.numeric(max) - as.numeric(load),
                         "\nused:", percent( perc, accuracy = 0.1 ) ) ) %>% 
  select( subsystem, registered_and_hostname, test, perc, label )

# calc memory
load_mem <- the_data %>% 
  filter( test == "load_mem" ) %>%
  select( subsystem, test, value, registered_and_hostname ) %>% 
  separate( col = value,
            into = c( "load", "max" ),
            sep = "/" ) %>%
  mutate( load_value = as.numeric( gsub("[a-zA-Z]", "", load ) ),
          load_unit = gsub("[^a-zA-Z]", "", load ) ) %>% 
  mutate( max_value = as.numeric( gsub("[a-zA-Z]", "", max ) ),
          max_unit = gsub("[^a-zA-Z]", "", max ) ) %>% 
  mutate( load_gigas = case_when( load_unit == "G" ~ load_value,
                                  load_unit == "T" ~ load_value * 1000 )  ) %>% 
  mutate( max_gigas = case_when( max_unit == "G" ~ max_value,
                                 max_unit == "T" ~ max_value * 1000 )  ) %>% 
  mutate( perc = load_gigas / max_gigas ) %>% 
  mutate( label = paste( "disp:", max_gigas - load_gigas, "G",
                         "\nused:", percent( perc, accuracy = 0.1 ) ) ) %>% 
  select( subsystem, registered_and_hostname, test, perc, label )

# calc root disk usage
load_rootdisk <- the_data %>% 
  filter( test == "load_rootdisk" ) %>%
  select( subsystem, test, value, registered_and_hostname ) %>% 
  separate( col = value,
            into = c( "used", "available" ),
            sep = "," ) %>% 
  mutate( used = str_remove( string = used,
                             pattern = "used_" ),
          available = str_remove( string = available,
                                  pattern = "available_" ) ) %>% 
  mutate( used_value = as.numeric( gsub("[a-zA-Z]", "", used ) ),
          used_unit = gsub("[^a-zA-Z]", "", used ) ) %>% 
  mutate( available_value = as.numeric( gsub("[a-zA-Z]", "", available ) ),
          available_unit = gsub("[^a-zA-Z]", "", available ) ) %>% 
  mutate( used_gigas = case_when( used_unit == "G" ~ used_value,
                                  used_unit == "T" ~ used_value * 1000 )  ) %>% 
  mutate( available_gigas = case_when( available_unit == "G" ~ available_value,
                                       available_unit == "T" ~ available_value * 1000 )  ) %>% 
  mutate( total_gigas = used_gigas + available_gigas ) %>% 
  mutate( perc = used_gigas / total_gigas ) %>% 
  mutate( label = paste( "disp:", available_gigas, "G",
                         "\nused:", percent( perc, accuracy = 0.1 ) ) ) %>% 
  select( subsystem, registered_and_hostname, test, perc, label )

# calc max component temperature
maxtemp_C <- the_data %>% 
  filter( test == "maxtemp_C" ) %>%
  select( subsystem, registered_and_hostname, test, value ) %>% 
  mutate( perc = as.numeric( value ) / 100,
          label = paste( value, "°C" ) ) %>% 
  select( subsystem, registered_and_hostname, test, perc, label )

# gather resources
all_resources <- bind_rows( load_avg_1min, load_mem, load_rootdisk, maxtemp_C )

# plot the resources
all_resources.p <- ggplot( data = all_resources,
                           mapping = aes( x = test,
                                          y = registered_and_hostname,
                                          fill = perc,
                                          label = label ) ) +
  geom_tile( color = "white", alpha = 0.3, size = 3 ) +
  geom_text( ) +
  scale_y_discrete( limits = unique( ordered_servers$registered_and_hostname ) ) +
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

# save plot for easy loading
saveRDS( object = all_resources.p,
         file = "all_resources.rds" )

### plot Oldest top3disks ====
top3disks <- the_data %>% 
  filter( test == "top3disks" ) %>% 
  select( subsystem, registered_and_hostname, value ) %>% 
  separate( col = value,
            into = paste0( "c", 1:3 ),
            sep = ",",
            remove = TRUE ) %>% 
  rename( used = c1,
          available = c2,
          disk = c3 ) %>% 
  mutate( used = str_remove( string = used, pattern = "used_" ),
          available = str_remove( string = available, pattern = "available_" ),
          disk = str_replace( string = disk, pattern = "disk_", replacement = "@" ),
          disk = paste0( registered_and_hostname, disk ) ) %>% 
  select( -registered_and_hostname ) %>% 
  mutate( used_value = as.numeric( gsub("[a-zA-Z]", "", used ) ),
          used_unit = gsub("[^a-zA-Z]", "", used ) ) %>% 
  mutate( available_value = as.numeric( gsub("[a-zA-Z]", "", available ) ),
          available_unit = gsub("[^a-zA-Z]", "", available ) ) %>% 
  mutate( used_unit = ifelse( test = used_value == 0,
                              yes = "G",
                              no = used_unit ) ) %>% 
  mutate( available_unit = ifelse( test = available_value == 0,
                                   yes = "G",
                                   no = available_unit ) ) %>% 
  mutate( used_gigas = case_when( used_unit == "G" ~ used_value,
                                  used_unit == "T" ~ used_value * 1000,
                                  used_unit == "P" ~ used_value * 1000000 )  ) %>% 
  mutate( available_gigas = case_when( available_unit == "G" ~ available_value,
                                       available_unit == "T" ~ available_value * 1000,
                                       available_unit == "P" ~ available_value * 1000000 )  ) %>%
  mutate( total_gigas = used_gigas + available_gigas ) %>% 
  mutate( perc = used_gigas / total_gigas ) %>% 
  mutate( label = paste( "disp:", available_gigas, "G",
                         "\nused:", percent( perc, accuracy = 0.1 ) ) ) %>% 
  select( subsystem, disk, perc )

# plot columns for offending %disk

top3disks.p <- ggplot( mapping = aes( x = disk,
                                      y = perc ) ) +
  geom_col( data = filter( top3disks, perc < max_fracc_for_waring_on_top3disk ),
            width = 0.1, fill = "gray50" ) +
  geom_col( data = filter( top3disks, perc >= max_fracc_for_waring_on_top3disk ),
            width = 0.1, fill = "tomato" ) +
  geom_text( data = filter( top3disks, perc >= max_fracc_for_waring_on_top3disk ),
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

# save plot for easy loading
saveRDS( object = top3disks.p,
         file = "top3disks.rds" )

### zpool_list;NAME_SIZE_ALLOC_FREE_EXPANDSZ_FRAG_CAP_DEDUP_HEALTH_ALTROOT ====
