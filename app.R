## app.R ##
library(shinydashboard)

library("ggplot2")
library("vroom")
library("dplyr")

# source all the functions
source( file = "scripts/shiny-scripts.R" )

ui <- dashboardPage( skin = "purple",
                     dashboardHeader( title = "Cluster Inmegen" ),
                     dashboardSidebar(
                       # agregamos menu
                       sidebarMenu(
                         # Use icons from https://getbootstrap.com/docs/3.4/components/#glyphicons
                         menuItem( "Recursos por nodos",
                                   tabName = "nodes",
                                   icon = icon( "tasks", lib = "glyphicon"  ) ),
                         menuItem( "Usuarios",
                                   tabName = "users",
                                   icon = icon( "user", lib = "glyphicon" ) ),
                         menuItem( "Reglamento",
                                   tabName = "rules",
                                   icon = icon( "book", lib = "glyphicon" ) ),
                         # menuItem( "Software instalado",
                         #           tabName = "installed",
                         #           icon = icon( "wrench", lib = "glyphicon" ) ),
                         # menuItem( "Solicita una cuenta",
                         #           tabName = "register",
                         #           icon = icon( "edit", lib = "glyphicon" ) ),
                         menuItem( "Contacto",
                                   tabName = "contact",
                                   icon = icon( "send", lib = "glyphicon" ) ),
                         menuItem( "Agradecimientos",
                                   tabName = "thanks",
                                   icon = icon( "star", lib = "glyphicon" ) )
                       )
                       
                     ),
                     dashboardBody(
                       tabItems(
                         # First tab content
                         tabItem( tabName = "nodes",
                                  # Boxes need to be put in a row (or column)
                                  fluidRow(
                                    # box( plotOutput( "nodos_recursos", height = 500 ) ),
                                    # box( plotOutput( "top3disks", height = 500 ) )
                                  ),
                                  fluidRow(
                                    box( plotOutput( "nodos_online", height = 500 ) )
                                    
                                  )
                         ), # Este cierra la pestania mainboard
                         tabItem( tabName = "users",
                                  fluidRow(
                                    # box( plotOutput( "vieja_conexion", height = 500 ) ),
                                    # box( plotOutput( "numero_procesos", height = 1000 ) )
                                  )
                         ),
                         tabItem( tabName = "rules",
                                  tags$iframe( style = "height:800px; width:100%; scrolling = yes",
                                               src = "reglamentoclusterinmegen.pdf" )
                         ),
                         tabItem( tabName = "installed",
                                  # Boxes need to be put in a row (or column)
                                  fluidRow(
                                    box( title = "En construccion" )
                                  )
                         ),
                         tabItem( tabName = "register",
                                  # Boxes need to be put in a row (or column)
                                  fluidRow(
                                    box( title = "En construccion" )
                                  )
                         ),
                         tabItem( tabName = "contact",
                                  # Boxes need to be put in a row (or column)
                                  fluidRow(
                                    column(width = 10, offset = 0,
                                           includeMarkdown( "WWW/contacto.md" ) )
                                  )
                         ),
                         tabItem( tabName = "thanks",
                                  # Boxes need to be put in a row (or column)
                                  fluidRow(
                                    column(width = 10, offset = 0,
                                           includeMarkdown( "WWW/agradecimientos.md" ) )
                                  )
                         )
                       ) # este cierra el tabItems(
                     ) # este cierra el body del dashboard completo
)

server <- function(input, output) {

  ### ONLINE NODES PLOT 
  output$nodos_online <- renderPlot( online_test.f( the_file = "logs/online_test.tsv" ) )

  ### ----
  # output$vieja_conexion <- renderPlot(
  #   readRDS( file = "monitor-results/cluster_monitor-results/A-analyzeR/oldest_connection.rds" )
  # )
  # output$numero_procesos <- renderPlot(
  #   readRDS( file = "monitor-results/cluster_monitor-results/A-analyzeR/number_of_process.rds" )
  # )
  # output$nodos_recursos <- renderPlot(
  #   readRDS( file = "monitor-results/cluster_monitor-results/A-analyzeR/all_resources.rds" )
  # )
  # output$top3disks <- renderPlot(
  #   readRDS( file = "monitor-results/cluster_monitor-results/A-analyzeR/top3disks.rds" )
  # )
  
}

shinyApp(ui, server)
