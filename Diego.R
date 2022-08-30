## app.R ##
library(shiny)
library(shinydashboard)
library(readr)
library(tidyr)
library(DT)

#Este apartado es dedicado a recolectar los documentos con los que vamos a trabajar
#Como son las tablas, los archivos PFD y los textos
Cambio <- read_csv("Divisas_pandemia.csv")# Esta es la tabla dirigida al apartado de usuarios
#Aqui ocupamos la ruta del archivo .txt, para posteriormente entregar los parametros al objeto Bienvenida
ruta<-"/home/descalera/Documentos/App-1/PryctIsra2/Brenda.txt"
Bienvenida_txt <- read.table(ruta, header=T, sep = "\t")
#De igual manera, para los problemas
ruta1<-"/home/descalera/Documentos/App-1/PryctIsra2/Problemas.txt"
Problemas_txt <- read.table(ruta1, header=T, sep = "\t")
#El material para la tabla de nodos
Nodal <- read_csv("RiesgosPI2.csv")

#
#Inicio de la programación
#Creamos una pagina
ui <- dashboardPage( skin = "purple",
                     dashboardHeader( title = "Cluster Inmegen",
                                      dropdownMenu(type = "messages",
                                                   messageItem(from = "Israel",
                                                               "Bienvenido"))
                                      ),
                     
                     #Creamos el menú a un costado
                     dashboardSidebar(
                       #Agregamos un buscador
                       sidebarSearchForm("searchText", "buttonSearch", "Buscar"),
                       # agregamos menu
                       sidebarMenu(
                         #Listado de elementos dentro del menu
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
                         menuItem( "Usuarios",
                                   tabName = "datos",
                                   icon = icon("user")),
                         menuItem( "Solicita una cuenta",
                                   tabName = "register",
                                   icon = icon( "edit", lib = "glyphicon" ) ),
                         menuItem( "Problemas",
                                   tabName = "Issues",
                                   icon = icon("hammer")),
                         menuItem( "Contacto",
                                   tabName = "contact",
                                   icon = icon( "send", lib = "glyphicon" ) ),
                         menuItem( "Agradecimientos",
                                   tabName = "thanks",
                                   icon = icon( "star", lib = "glyphicon" ) )
                       )
                       
                     ),
                     
                     #Contenido dentro de los elementos del menú 
                     dashboardBody(
                       tabItems(
                         # First tab content
                         tabItem( tabName = "mainboard",
                                  # Boxes need to be put in a row (or column)
                                  fluidRow(
                                    box( plotOutput( "nodos_online", height = 250 ) ),
                                    box( title = "En construccion",
                                         DT::dataTableOutput("Inicio"))
                                  )
                         ), # Este cierra la pestaña mainboard
                         tabItem( tabName = "rules",
                                  tags$iframe(style="height:400px; width:100%; scrolling=yes",
                                              src="Reglas de uso CLUSTER INMEGEN Enero 2022.pdf")
                         ),
                         tabItem( tabName = "installed",
                                  # Boxes need to be put in a row (or column)
                                  fluidRow(
                                    box( title = "En construccion" )
                                  )
                         ),
                         tabItem( tabName = "datos",
                                  DT::dataTableOutput("datos")),
                         tabItem( tabName = "register",
                                  # Boxes need to be put in a row (or column)
                                  fluidRow(
                                    box( title = "En construccion",
                                         DT::dataTableOutput("Nodos"))
                                  )
                         ),
                         tabItem(tabName = "Issues",
                                 DT::dataTableOutput("Issues")),
                         tabItem( tabName = "contact",
                                  # Boxes need to be put in a row (or column)
                                  fluidRow(
                                    box( title = "Contacto",
                                         tags$image(type="image/jpg",
                                                    src="Contactas.jpg",
                                                    controls="controls"),
                                         width=5, status="primary", solidHeader = T),
                                    box(title = "Información del Contacto",
                                        h1(strong("Israel Aguilar Ordoñez")),
                                        h3("Telefono: 55 2025-1200"),
                                        h3("COrreo electrónico: iaguilar_o@gmail.com"))
                                  )
                         ),
                         tabItem( tabName = "thanks",
                                  # Boxes need to be put in a row (or column)
                                  fluidRow(
                                    box( title = "Agradecimientos",
                                         tags$image(type="image/jpg",
                                                    src="Agradecimientas.jpg",
                                                    controls="controls", 
                                                    height="400px", width="600px"),
                                         width=5, status="primary", solidHeader = T),
                                    box(title = "Agradecimientos",
                                        p(h3("El", strong("INSTITUTO NACIONAL DE MEDICINA GENOMICA (INMEGEN), "),
                                             "agradece la participaciòn del bioinformatico ",
                                                           strong("Israel Aguilar Ordoñez")))
                                        ) #Este cierra el segundo box
                                  ) #Este cierra el fluidRow
                         ) #Este cierra el tabItem
                       ) # este cierra el tabItems(
                     ) # este cierra el body del dashboard completo
)

server <- function(input, output) {
  output$Inicio <- DT::renderDataTable(Bienvenida_txt)
  output$datos <- DT::renderDataTable(Cambio)
  output$Issues <- DT::renderDataTable(Problemas_txt)
  output$nodos_online <- renderPlot(
    readRDS( file = "logs/imagen_nodos_online.rds" )
  )
  output$imag <- renderImage({
    return(list(src = "Agradecimientas.jpg", contentType = "image/jpg"))
  })
  output$Contacto <- renderImage({
    return(list(src = "Contactas.jpg", contentType="image/jpg"))
  })
}

shinyApp(ui, server)
