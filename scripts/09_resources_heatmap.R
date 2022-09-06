# load libs
library("pacman")

p_load( "vroom",
        "dplyr",
        "ggplot2",
        "tidyr",
        "lubridate",
        "stringr",
        "scales" )

#read args from command line
args <- commandArgs( trailingOnly = TRUE )

# pass args to objects
ifile <- args[1] # "../logs/recursos_por_nodo.log.gz" 
ofile <- args[2]

# create a function do remove magnitud and multiply number
mag_remover <- function( the_value, the_multiplier ) {
  str_remove_all( string = the_value,
                  pattern = "[a-zA-Z]" ) %>% 
    as.numeric( ) * the_multiplier
}

giga_adjuster <- function( the_value ) {
  case_when( str_detect( string = the_value,
                         pattern = "T" ) ~ mag_remover( the_value = the_value, the_multiplier = 1000 ),
             str_detect( string = the_value,
                         pattern = "G" ) ~ mag_remover( the_value = the_value, the_multiplier = 1 ),
             str_detect( string = the_value,
                         pattern = "M" ) ~ mag_remover( the_value = the_value, the_multiplier = 0.001 ),
             TRUE ~ as.numeric(NA)
  )
}

# read data
nodos <- read.table( file = ifile,
                     sep = "\t",
                     header = FALSE ) %>% 
  rename( timestamp = 1,
          nodo = 2,
          totalcpu = 3,
          loadcpu = 4,
          totalmem = 5,
          usedmem = 6,
          available_disk = 7,
          used_disk = 8 ) %>% 
  separate( col =  timestamp,
            into = c( "dia", "fecha", "hora" ),
            sep = "_" ) %>% 
  mutate( fecha2 = dmy(fecha),
          hora2 = hm(hora) ) %>% 
  group_by( nodo ) %>% 
  arrange( nodo, fecha2, hora2 ) %>% 
  slice( n( ) ) %>%    # extract the last line after arrange
  ungroup( ) %>% 
  mutate( adj_totalmem = giga_adjuster( the_value = totalmem ),
          .after = totalmem ) %>% 
  mutate( adj_usedmem = giga_adjuster( the_value = usedmem ),
          .after = usedmem ) %>% 
  mutate( adj_available_disk = giga_adjuster( the_value = available_disk ),
          .after = available_disk ) %>% 
  mutate( adj_used_disk = giga_adjuster( the_value = used_disk ),
          .after = used_disk )

# recalcula valores utiles
recalc <- nodos %>% 
  mutate( .after = nodo,
          percent_usedcpu = loadcpu / totalcpu,
          free_cpu = totalcpu - loadcpu,
          percent_usedmem = adj_usedmem / adj_totalmem,
          free_mem = adj_totalmem - adj_usedmem,
          percent_used_disk = adj_used_disk / ( adj_used_disk + adj_available_disk ),
          free_disk = adj_available_disk  )

# prepare df for res type
cpu <- recalc %>% 
  select( nodo, percent_usedcpu, free_cpu ) %>% 
  pivot_longer( cols = free_cpu,
                names_to = "resource",
                values_to = "available" ) %>% 
  rename( percent_used = percent_usedcpu )

# next resource
mem <- recalc %>% 
  select( nodo, percent_usedmem, free_mem ) %>% 
  pivot_longer( cols = free_mem,
                names_to = "resource",
                values_to = "available" ) %>% 
  rename( percent_used = percent_usedmem )

# next resource
disk <- recalc %>% 
  select( nodo, percent_used_disk, free_disk ) %>% 
  pivot_longer( cols = free_disk,
                names_to = "resource",
                values_to = "available" ) %>% 
  rename( percent_used = percent_used_disk )

# bind res dfs
fortiles <- bind_rows( cpu, mem, disk )

res_heatmap <- ggplot( data = fortiles,
                       mapping = aes( x = resource,
                                      y = nodo,
                                      fill = percent_used ) ) +
  geom_tile( color = "black", size = 0.7,
             height = 0.7,
             width = 0.7 ) +
  geom_text( mapping = aes( label = floor( available ) ),
             size = 4 ) +
  scale_fill_gradient2( low = "limegreen",
                        mid = "yellow",
                        high = "tomato",
                        midpoint = 0.5, 
                        limit = c(0 , 1),
                        breaks = c(0, 0.5, 1),
                        labels = percent ) +
  scale_x_discrete( position = "top", limits = c( "free_cpu",
                                                  "free_mem",
                                                  "free_disk" ),
                    labels = c( "CPUs\n(threads)",
                                "RAM\nen GB",
                                "Disco Duro (/)\nen GB") ) +
  labs( title = "Recursos Libres por Nodo",
        fill = "% de recurso\nusado\n",
        caption = paste("Ultima revision",
                         unique( nodos$dia),
                         unique( nodos$fecha ),
                         unique( nodos$hora ) ) ) +
  theme_void( base_size = 15 ) +
  guides( fill = guide_colourbar( title.hjust = 0.5,
                                  frame.colour = "black",
                                  ticks.colour = "black" ) ) +
  theme( 
    axis.text.x = element_text( size = 10 ),
    axis.text.y = element_text( face = "bold" ),
    legend.text = element_text( size = 10 ),
    legend.title = element_text( size = 12 ),
    plot.caption = element_text( hjust = 1,
                                  size = 8 ),
    plot.title = element_text( hjust = 0.5 )
  )


# save plot for easy loading
saveRDS( res_heatmap,
         file = ofile )
