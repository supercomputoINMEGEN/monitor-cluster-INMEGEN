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
                         menuItem( "Software instalado",
                                   tabName = "installed",
                                   icon = icon( "wrench", lib = "glyphicon" ) ),
                         menuItem( "Solicita una cuenta",
                                   tabName = "register",
                                   icon = icon( "edit", lib = "glyphicon" ) ),
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
                                    box( plotOutput( "nodos_online", height = 250 ) ),
                                    box( title = "En construccion" )
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
                                    box( title = "En construccion" )
                                  )
                         ),
                         tabItem( tabName = "thanks",
                                  # Boxes need to be put in a row (or column)
                                  fluidRow(
                                    box( title = "En construccion" )
                                  )
                         )
                       ) # este cierra el tabItems(
                     ) # este cierra el body del dashboard completo
)

server <- function(input, output) {
  
  output$nodos_online <- renderPlot(
    readRDS( file = "logs/imagen_nodos_online.rds" )
  )
}

shinyApp(ui, server)
