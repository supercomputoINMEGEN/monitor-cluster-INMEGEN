library("shiny")
library("DT")
library("vroom")
library("ggplot2")
library("tidyr")
library("dplyr")

# Define UI
ui <- fluidPage(
  titlePanel("Usuarios Dashboard"),
  sidebarLayout(
    sidebarPanel(
      # Add any sidebar inputs if needed
    ),
    mainPanel(
      selectInput("user_select", "Select User", choices = NULL),
      plotOutput("heatmap"),
      dataTableOutput("filtered_data_table")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Read the data
  all_usuarios <- vroom( file = "logs/allusers.tsv" )
  
  # get all the possible hostnames
  allhostnames <- all_usuarios %>% 
    select( registered_and_hostname ) %>% 
    unique( ) %>% 
    mutate( default = "missing" ) %>% 
    arrange( registered_and_hostname )
  
  # Update user selection choices
  users <- unique(all_usuarios$user) %>% sort( )
  updateSelectInput( session, "user_select", choices = users )
  
  # Render the heatmap
  output$heatmap <- renderPlot({
    
    # Filter data based on user selection
    filtered_data <- subset( x = all_usuarios,
                             user == input$user_select ) %>%
      mutate( col_tag = ifelse( test = length( unique( pull( ., UID) ) ) == 1 ,
                                no = "fail" , yes = "ok" ) )
    
    # mix filtered and defaults
    mixed_data <- left_join( x = allhostnames,
                             y = filtered_data,
                             by = "registered_and_hostname" ) %>% 
      mutate( user = unique( na.omit( pull( ., user ) ) ),
              col_tag = ifelse( test = is.na( col_tag ),
                                yes = "missing", no = col_tag ))
    
    # Create the heatmap plot
    ggplot(data = mixed_data,
           aes(x = registered_and_hostname,
               y = user,
               label = UID,
               fill = col_tag )) +
      geom_tile( color = "black" ) +
      geom_text( ) +
      scale_x_discrete( limits = allhostnames$registered_and_hostname ) +
      scale_fill_manual( values = c( "fail" = "tomato", "ok" = "skyblue", "missing" = "white" ) ) +
      labs( title = "Propagacion de usuarios",
            x = "Registered and Hostname",
            y = "User",
            fill = "UID test" ) +
      theme_minimal() +
      theme( axis.text.x = element_text( angle = 90, hjust = 0.5 ) )
  })
  
  # Render the filtered_data table
  output$filtered_data_table <- renderDataTable({
    filtered_data <- subset( x = all_usuarios,
                             user == input$user_select)
    datatable(filtered_data)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
