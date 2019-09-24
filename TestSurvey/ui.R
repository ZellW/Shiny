library(shiny)
library(shinythemes)

# Define UI for slider demo application
shinyUI(pageWithSidebar(
  
  #  Application title
  headerPanel("Ally Data Science Collaborative"),
  
  sidebarPanel(
      # This is intentionally an empty object.
      h6(textOutput("save.results")),
      h5("Created by Ally Data Scientists"),
            h5("For details on how to build this:"),
            tags$a("The Collaborative Sharepoint Site", 
                   href=paste0("https://supplier-world.int.ally.com/sites/CIA/SitePages/Welcome%20to%20the%20Data%20Science%20Workbench%20Site!.aspx")),
            # Display the page counter text.
            h5(textOutput("counter"))
      ),

  
  # Show a table summarizing the values entered
  mainPanel(
    # Main Action is where most everything is happenning in the
    # object (where the welcome message, survey, and results appear)
    uiOutput("MainAction"),
    # This displays the action putton Next.
    actionButton("Click.Counter", "Next")    
    )
))
