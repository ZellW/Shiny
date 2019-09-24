#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- dashboardPage(
    dashboardHeader(title = "Example Audio Play"),
    
    dashboardSidebar(
        sidebarMenu(
            menuItem("Play Audio", tabName = "playaudio", icon = icon("dashboard"))
        )),
    
    dashboardBody(
        tabItems(
            tabItem(tabName = "playaudio",
                    fluidRow(
                        box(title = "Controls", width = 4,
                            actionButton("playsound", label = "Play The Rebuilt Sound!"))
                    )
            )
        )
    )
)

server <- function(input, output) {
    Soundwav <- Wave(left = Soundfile, samp.rate = 44100, bit = 16)
    savewav(Soundwav, filename = "www\\Soundwavexported.wav")
    
    
    observeEvent(input$playsound, {
        insertUI(selector = "#playsound",
                 where = "afterEnd",
                 ui = tags$audio(src = "Soundwavexported.wav", type = "audio/wav", autoplay = NA, controls = NA, style="display:none;")
        )
    })
    
}


shinyApp(ui, server)
