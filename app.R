## app.R ##
library(shinydashboard)

ui <- dashboardPage( skin = "purple",
                     dashboardHeader( title = "Cluster Inmegen" ),
                     dashboardSidebar(
                       # agregamos menu
                       sidebarMenu(
                         # Use icons from https://getbootstrap.com/docs/3.4/components/#glyphicons
                         menuItem( "Principal",
                                   tabName = "mainboard",
                                   icon = icon( "tasks", lib = "glyphicon"  ) ),
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
                         tabItem( tabName = "mainboard",
                                  # Boxes need to be put in a row (or column)
                                  fluidRow(
                                    box( plotOutput( "nodos_recursos", height = 500 ) ),
                                    box( plotOutput( "vieja_conexion", height = 500 ) )
                                    # box( plotOutput( "slots_disponibilidad", height = 250 ) )
                                  ),
                                  fluidRow(
                                    box( plotOutput( "nodos_online", height = 250 ) ),
                                    box( plotOutput( "numero_procesos", height = 1000 ) )
                                    
                                  )
                         ), # Este cierra la pestania mainboard
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
  
  output$nodos_online <- renderPlot(
    readRDS( file = "test/results/cluster_monitor-results/A-analyzeR/online_test.rds" )
  )
  output$vieja_conexion <- renderPlot(
    readRDS( file = "test/results/cluster_monitor-results/A-analyzeR/oldest_connection.rds" )
  )
  output$numero_procesos <- renderPlot(
    readRDS( file = "test/results/cluster_monitor-results/A-analyzeR/number_of_process.rds" )
  )
  # output$slots_disponibilidad <- renderPlot(
  #   readRDS( file = "logs/imagen_disponibilidad.rds" )
  # )
  output$nodos_recursos <- renderPlot(
    readRDS( file = "test/results/cluster_monitor-results/A-analyzeR/all_resources.rds" )
  )
}

shinyApp(ui, server)
