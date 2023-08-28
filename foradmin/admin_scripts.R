# load pkgs
pacman::p_load( "vroom", "dplyr", "ggplot2" )

# Funcion for user heatmap
user_propagation.f <- function( the_data, the_user, the_hostnames ) {
  
  # Filter data based on user selection    
  filtered_data <- subset( x = the_data,
                           user == the_user ) %>%
    mutate( col_tag = ifelse(test = length( unique( pull( ., UID ) ) ) == 1,
                             no = "fail", yes = "ok") )
  
  # mix filtered and defaults    
  mixed_data <- left_join( x = the_hostnames,
                           y = filtered_data,
                           by = "registered_and_hostname" ) %>%       
    mutate( user = unique( na.omit( pull( ., user ) ) ),
            col_tag = ifelse( test = is.na( col_tag ),
                              yes = "missing", no = col_tag ) )
  
  # Create the heatmap plot    
  ggplot( data = mixed_data,
          mapping = aes( x = registered_and_hostname,
                         y = user,
                         label = UID,
                         fill = col_tag ) ) +
    geom_tile( color = "black" ) +      
    geom_text( ) +
    scale_x_discrete( limits = the_hostnames$registered_and_hostname ) +
    scale_fill_manual( values = c( "fail" = "tomato",
                                   "ok" = "skyblue",
                                   "missing" = "white" ) ) +
    labs( title = "Propagacion de usuarios",           
          x = "Registered and Hostname",
          y = "User",           
          fill = "Homo-UID test",
          caption = "This test shows if a user has the same UID in every node" ) +
    theme_minimal( base_size = 15 ) +
    theme( axis.text.x = element_text( angle = 90, hjust = 0.5 ) )
  
}

# Funcion for group heatmap
group_propagation.f <- function( the_data, the_group, the_hostnames ) {
  
  # Filter data based on user selection
  filtered_data <- subset( x = the_data,
                           gp == the_group ) %>%
    mutate( col_tag = ifelse( test = length( unique( pull( ., GID ) ) ) == 1,
                             no = "fail", yes = "ok") )
  
  # mix filtered and defaults
  mixed_data <- left_join( x = the_hostnames,
                           y = filtered_data,
                           by = "registered_and_hostname" ) %>%
    mutate( gp = unique( na.omit( pull( ., gp ) ) ),
            col_tag = ifelse( test = is.na( col_tag ),
                              yes = "missing", no = col_tag ) )
  
  # Create the heatmap plot
  ggplot( data = mixed_data,
          mapping = aes( x = registered_and_hostname,
                         y = gp,
                         label = GID,
                         fill = col_tag ) ) +
    geom_tile( color = "black" ) +
    geom_text( ) +
    scale_x_discrete( limits = the_hostnames$registered_and_hostname ) +
    scale_fill_manual( values = c( "fail" = "tomato",
                                   "ok" = "skyblue",
                                   "missing" = "white" ) ) +
    labs( title = "Propagacion de Grupos",
          x = "Registered and Hostname",
          y = "Group",
          fill = "Homo-GID test",
          caption = "This test shows if a group has the same GID in every node" ) +
    theme_minimal( base_size = 15 ) +
    theme( axis.text.x = element_text( angle = 90, hjust = 0.5 ) )
  
}
