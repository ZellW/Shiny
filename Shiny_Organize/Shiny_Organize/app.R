#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
    titlePanel("List and Source UI"), # Title Page
    
    # Sidebar with a slider input for number of bins
    sidebarLayout(  
        sidebarPanel( # The Side Bar
            tabsetPanel(
                tabPanel("Panel 1", source(file = "Side_Panel_CTRL.R", local = T)[1]),
                tabPanel("Panel 2", source(file = "Side_Panel2_CTRL.R", local = T)[1])
            )
        ),
        # Show a plot of the generated distribution    
        mainPanel( 
            source(file="Main_Panel_OUTPUT.R", local=T)[1]
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    output$distPlot <- renderPlot({
        source(file="Server_Plot.R", local=T) 
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
