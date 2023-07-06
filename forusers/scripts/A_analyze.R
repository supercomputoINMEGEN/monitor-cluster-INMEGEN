# load libs

# install.packages( "pacman", repos = "http://cran.us.r-project.org" )
library("pacman")

p_load( "vroom",
        "dplyr",
        "ggplot2",
        "tidyr",
        "lubridate",
        "stringr",
        "scales",
        "gdata" )

# source all the functions
source( file = "shiny-scripts.R" )

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
                     str_replace( string = the_time, pattern = ":", replacement = "-" ),
                     "monitor-cluster-log.tsv", sep = "_" )

the_data %>% 
  select( -ip_or_domain, -port, -login, -date, -time, -registered_and_hostname  ) %>% 
  write.table( x = ., 
               file = ofile_tsv,
               append = FALSE, quote = FALSE, sep = "\t",
               row.names = FALSE, col.names = TRUE )

system( "gzip -9 *_monitor-cluster-log.tsv" )


# get uniq test names
the_data$test %>% unique( )

### plot online data ====
online_test <- the_data %>% 
  filter( test == "ssh_connection" ) %>% 
  select( subsystem, registered_name, value, hostname, registered_and_hostname ) %>% 
  mutate( value = ifelse( test = is.na( value ),
                          yes = "OFFLINE", no = value ) )

# save the dataframe for dynamic plotting
online_test %>% 
  mutate( the_subtitle = the_subtitle,
          the_caption = the_caption ) %>% 
  write.table( x = .,
               file = "online_test.tsv",
               append = FALSE,
               quote = FALSE,
               sep = "\t",
               row.names = FALSE,
               col.names = TRUE )

# plot the data
online_test.f( the_file = "online_test.tsv" )

### plot number_processes ====
number_of_process <- the_data %>% 
  filter( test == "number_processes" ) %>% 
  select( subsystem, registered_name, user, value, hostname, registered_and_hostname ) %>%
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

# save the dataframe for dynamic plotting
number_of_process %>%
  write.table( x = .,
               file = "number_of_process.tsv",
               append = FALSE,
               quote = FALSE,
               sep = "\t",
               row.names = FALSE,
               col.names = TRUE )

# save the dataframe for dynamic plotting
percent_process %>%
  write.table( x = .,
               file = "percent_process.tsv",
               append = FALSE,
               quote = FALSE,
               sep = "\t",
               row.names = FALSE,
               col.names = TRUE )

# save the dataframe for dynamic plotting
ordered_process %>%
  write.table( x = .,
               file = "ordered_process.tsv",
               append = FALSE,
               quote = FALSE,
               sep = "\t",
               row.names = FALSE,
               col.names = TRUE )

# do plot with function
number_of_process.f( the_number_of_process = "number_of_process.tsv",
                     the_percent_process = "percent_process.tsv",
                     the_ordered_process = "ordered_process.tsv" )

### plot Oldest conections ====
oldest_connection <- the_data %>% 
  filter( test == "oldest_connection" ) %>% 
  select( subsystem, registered_name, user, value, hostname, registered_and_hostname ) %>%
  mutate( fecha = dmy( value, quiet = TRUE ) ) %>% 
  filter( ! is.na( hostname ) ) %>% 
  mutate( oldest_conn = interval( fecha, ymd(the_date) ) %/% days(1),   # calculate number of days to the oldest connection
          fecha_flag = ifelse( test = oldest_conn > max_days_for_connection,
                               yes = "Warning",
                               no = "OK") ) %>% 
  select( subsystem, hostname, registered_name, registered_and_hostname, user, oldest_conn, fecha_flag ) %>% 
  arrange( user, -oldest_conn ) %>% 
  group_by( hostname, user ) %>% 
  slice( 1 ) %>% 
  ungroup( ) %>% 
  arrange( oldest_conn )

# save the dataframe for dynamic plotting
oldest_connection %>%
  write.table( x = .,
               file = "oldest_connection.tsv",
               append = FALSE,
               quote = FALSE,
               sep = "\t",
               row.names = FALSE,
               col.names = TRUE )

oldest_connection.f( the_data = "oldest_connection.tsv" )

### plot load_avg_1min, load_mem, load_rootdisk, maxtemp_C ====
# calc processor
load_avg_1min <- the_data %>% 
  filter( test == "load_avg_1min" ) %>%
  select( subsystem, test, value, registered_and_hostname, registered_name ) %>% 
  separate( col = value,
            into = c( "load", "max" ),
            sep = "/" ) %>% 
  mutate( perc = as.numeric( load ) /
            as.numeric( max ) ) %>% 
  mutate( label = paste( "disp:", as.numeric(max) - as.numeric(load),
                         "_used:", percent( perc, accuracy = 0.1 ) ) ) %>% 
  select( subsystem, registered_name, registered_and_hostname, test, perc, label )

# calc memory
load_mem <- the_data %>% 
  filter( test == "load_mem" ) %>%
  select( subsystem, test, value, registered_and_hostname, registered_name ) %>% 
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
                         "_used:", percent( perc, accuracy = 0.1 ) ) ) %>% 
  select( subsystem, registered_name, registered_and_hostname, test, perc, label )

# calc root disk usage
load_rootdisk <- the_data %>% 
  filter( test == "load_rootdisk" ) %>%
  select( subsystem, test, value, registered_and_hostname, registered_name ) %>% 
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
                         "_used:", percent( perc, accuracy = 0.1 ) ) ) %>% 
  select( subsystem, registered_name, registered_and_hostname, test, perc, label )

# calc max component temperature
maxtemp_C <- the_data %>% 
  filter( test == "maxtemp_C" ) %>%
  select( subsystem, registered_and_hostname, test, value, registered_name ) %>% 
  mutate( perc = as.numeric( value ) / 100,
          label = paste( value, "°C" ) ) %>% 
  select( subsystem, registered_name, registered_and_hostname, test, perc, label )

# gather resources
all_resources <- bind_rows( load_avg_1min, load_mem, load_rootdisk, maxtemp_C )

# save the dataframe for dynamic plotting
all_resources %>%
  write.table( x = .,
               file = "all_resources.tsv",
               append = FALSE,
               quote = FALSE,
               sep = "\t",
               row.names = FALSE,
               col.names = TRUE )

all_resources.f( the_data = "all_resources.tsv" )

### plot Oldest top3disks ====
top3disks <- the_data %>% 
  filter( test == "top3disks" ) %>% 
  select( subsystem, registered_name, registered_and_hostname, value ) %>% 
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
                         "_used:", percent( perc, accuracy = 0.1 ) ) ) %>% 
  select( subsystem, registered_name, registered_and_hostname, disk, perc )

# save the dataframe for dynamic plotting
top3disks %>%
  write.table( x = .,
               file = "disk.tsv",
               append = FALSE,
               quote = FALSE,
               sep = "\t",
               row.names = FALSE,
               col.names = TRUE )

top3disks.f( the_data = "disk.tsv" )

# extract useful user information
allusers <- the_data %>% 
  filter( test == "users" ) %>% 
  select( value, subsystem, registered_and_hostname, date, time ) %>% 
  separate( col = value,
            into = c("user", "x", "UID"),
            sep = ":" ) %>% 
  select( -x )

# save allusers
write.table( x = allusers,
             file = "allusers.tsv",
             append = FALSE,
             quote = FALSE,
             sep = "\t",
             row.names = FALSE,
             col.names = TRUE )

# extract useful group information
allgroups <- the_data %>% 
  filter( test == "groups" ) %>% 
  select( value, subsystem, registered_and_hostname, date, time ) %>% 
  separate( col = value,
            into = c("gp", "x", "GID"),
            sep = ":" ) %>%
  select( -x )

# save allusers
write.table( x = allgroups,
             file = "allgroups.tsv",
             append = FALSE,
             quote = FALSE,
             sep = "\t",
             row.names = FALSE,
             col.names = TRUE )

### zpool_list;NAME_SIZE_ALLOC_FREE_EXPANDSZ_FRAG_CAP_DEDUP_HEALTH_ALTROOT ====

