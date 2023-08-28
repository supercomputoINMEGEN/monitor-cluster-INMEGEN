## app.R ##
library("shinydashboard")
library("shiny")
library("DT")
library("vroom")
library("ggplot2")
library("tidyr")
library("dplyr")
library("shinyjs")

# source all the functions
source( file = "admin_scripts.R" )

ui <- dashboardPage(
  dashboardHeader(title = "Cluster Inmegen - Administracion"),  
  
  # The sidebar menus  
  dashboardSidebar(
    sidebarMenu(
      menuItem( text = "RAIDs",
                tabName = "raids",
                icon = icon( "hdd", lib = "glyphicon" ) ),
      menuItem( text = "Usuarios",
                tabName = "users",
                icon = icon( "user", lib = "glyphicon" ) ),
      menuItem( text = "Grupos",
                tabName = "groups",
                icon = icon( "menu-right", lib = "glyphicon" ) )
      
    ) # Fin del sidebarMenu  
  ), # Fin y coma del dashboardSidebar
  
  # The Body to show en la pagina
  dashboardBody( 
    useShinyjs(),
    
    # Página de inicio de sesión    
    tags$div(
      id = "login_div",
      style = "margin-top: 50px;",      
      wellPanel(
        textInput("username", "Nombre de usuario"),        
        passwordInput("password", "Contraseña"),
        br(),        
        actionButton("login_btn", "Iniciar sesión")
      )    
    ),
    
    # Contenido del dashboard (oculto inicialmente)
    tags$div(      
      id = "dashboard_content",
      style = "display: none;",      
      
      # Dividido por categoria del sidebar menu
      tabItems(        
        tabItem(
          tabName = "raids",
          fluidRow(
            box( title = "Estados de los RAIDs por Storcli",              
                 dataTableOutput( outputId = "table_storcli_OK" ),
                 width = 10 )
          ) # end fluidrow        
        ),
        
        # Primer tab conten; Usuarios
        tabItem(
          tabName = "users",
          fluidRow(            
            box( title = "Buscar USER",              
                 selectInput( inputId = "user_select",
                              label = "Seleccionar",                          
                              choices = NULL ), 
                 width = 3 ),            
            box( title = "Propagacion del Usuario",              
                 plotOutput( "heatmap_user" ),
                 width = 10 )
          ) # end fluidrow        
        ),
        tabItem(
          tabName = "groups",
          fluidRow(
            box( title = "Buscar GROUP",              
                 selectInput( inputId = "group_select",
                              label = "Seleccionar",                          
                              choices = NULL ), 
                 width = 3 ),
            box( title = "Propagacion del Grupo",              
                 plotOutput( "heatmap_groups" ),     ## probar con otro objeto que no sea el heatmap solo para ver si lo renderea
                 width = 10 )
          ) # end fluidrow        
        )
      ) #End of  tabItemS( )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Variables de usuario y contraseña unicos  
  valid_username <- "sbiadmin"
  valid_password <- "inmegen 2023"  
  
  # Variable para controlar si el usuario ha iniciado sesión  
  loggedin <- reactiveVal(FALSE)
  
  # Función para mostrar el contenido del dashboard cuando el usuario ha iniciado sesión
  showDashboardContent <- function() { 
    if (loggedin()) { 
      shinyjs::show("dashboard_content")  # Mostramos el contenido 
      shinyjs::hide("login_div")  # Ocultamos la página de inicio de sesión 
    } else { 
      shinyjs::hide("dashboard_content")  # Ocultamos el contenido 
      shinyjs::show("login_div")  # Mostramos la página de inicio de sesión 
    } 
  } 
  
  # Verificación de inicio de sesión  
  observeEvent(
    input$login_btn,
    {
      if (input$username == valid_username && input$password == valid_password) {      
        loggedin(TRUE)
        showDashboardContent()
      } else {      
        
        # Mostrar mensaje de error de inicio de sesión
        showModal(        
          modalDialog(
            title = "Error de inicio de sesión","Nombre de usuario o contraseña incorrectos.",easyClose = TRUE)
        )    }
    }
  )  
  
  # Read the data for RADIS
  all_storcli <- vroom(file = "logs/allstorcli.tsv") %>% 
    arrange( subsystem, Size_num ) %>% 
    rename( Size = Size_num,
            Unit = Size_mag,
            hostname = registered_and_hostname ) %>% 
    relocate( hostname, Name, Size, Unit, .before = 1 )
  
  storcli_OK <- all_storcli %>% 
    filter( State == "Optl" )
  
  storcli_BAD <- all_storcli %>% 
    filter( State != "Optl" )
  
  # Render the tables
  output$table_storcli_OK <- renderDataTable({
    datatable( storcli_OK )
  })
  
  output$table_storcli_BAD <- renderDataTable({
    datatable( storcli_BAD )
  })
  
  # Read the data  
  all_usuarios <- vroom(file = "logs/allusers.tsv")
  
  # get all the possible hostnames
  allhostnames <- all_usuarios %>%     
    select( registered_and_hostname ) %>% 
    unique( ) %>%     
    mutate( default = "missing" ) %>% 
    arrange( registered_and_hostname )
  
  # Update user selection choices  
  users <- unique( all_usuarios$user ) %>% sort( )
  
  updateSelectInput( session = session, inputId = "user_select", choices = users )
  
  # Render the heatmap for users
  output$heatmap_user <- renderPlot({
    
    user_propagation.f( the_data = all_usuarios,
                        the_user = input$user_select,
                        the_hostnames = allhostnames )
    
  })
  
  # Read the data  for groups
  all_groups <- vroom( file = "logs/allgroups.tsv" )
  
  # get all the possible hostnames
  allhostnames_2 <- allhostnames
  
  # Update groups selection choices  
  groups <- unique( all_groups$gp ) %>% sort( )
  
  updateSelectInput( session = session, inputId = "group_select", choices = groups )
  
  # Render the heatmap for users
  output$heatmap_groups <- renderPlot({
    
    group_propagation.f( the_data = all_groups,
                         the_group = input$group_select,
                         the_hostnames = allhostnames_2 )
    
  })
  
  # Mostrar el contenido del dashboard cuando el usuario ha iniciado sesión  
  observe({
    
    showDashboardContent( )
    
  })
  
}

shinyApp(ui, server)