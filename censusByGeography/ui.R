library(shiny)
library("shinythemes")

# Define UI for dataset viewer application
shinyUI(fixedPage(theme = shinytheme("flatly"),
                  
                  # Application title.
                  titlePanel("Census Data"),
                  
                  fixedRow(
                    column(3,
                      selectInput("dataset", "Choose a dataset:", 
                                  choices = c("Census Regions", "Census Divisions")),
                      
                      radioButtons("censusyear", "Census Year", c(2000, 2010)),
                      br(),
                      br(),
                      includeHTML("interesting.html")
                    ),
                    
                    column(9,
                      
                      tabsetPanel(
                        
                        h4("Selected Census Data"),
                        tabPanel("Data Table", DT::dataTableOutput("view"), value="thistab"),
                        tabPanel("Census Plot", plotOutput("dataplot")),
                        tabPanel("How To", includeMarkdown("datanotes_reg.md")),
                        selected = "thistab"
                        
                      )
                      
                    )
                  )
))