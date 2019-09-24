
library(shiny)
library(ggplot2)

## Some sample data
dat <- setNames(data.frame(matrix(runif(100),10)), letters[1:10])
dat$time <- seq(nrow(dat))

## Make some random plots because it looks cooler
## But you would just define your 10 different plots
rndmPlot <- function(input)
      sample(list(geom_line(), geom_bar(stat='identity'), geom_point(), geom_jitter(),
                  geom_density(aes_string(x=input$var), inherit.aes=FALSE)), 1)

makePlotContainers <- function(n, ncol=2, prefix="plot", height=100, width="100%", ...) {
      ## Validate inputs
      validateCssUnit(width)
      validateCssUnit(height)
      
      ## Construct plotOutputs
      lst <- lapply(seq.int(n), function(i)
            plotOutput(sprintf('%s_%g', prefix, i), height=height, width=width))
      
      ## Make columns
      lst <- lapply(split(lst, (seq.int(n)-1)%/%ncol), function(x) column(12/ncol, x))
      do.call(tagList, lst)
}

renderPlots <- function(n, input, output, prefix="plot") {
      for (i in seq.int(n)) {
            local({
                  ii <- i  # need i evaluated here
                  ## These would be your 10 plots instead
                  output[[sprintf('%s_%g', prefix, ii)]] <- renderPlot({
                        ggplot(dat, aes_string(x='time', y=input$var)) + rndmPlot(input)
                  })
            })
      }
}

ui <- shinyUI(
      fluidPage(
            sidebarLayout(
                  sidebarPanel(
                        sliderInput('nplots', 'Number of Plots', min=1, max=10, value=8),
                        selectInput("var", label = "Choose", choices=letters[1:10]),
                        textInput('height', 'Plot Height', value="100"),
                        textInput('width', 'Width', value="100%"),
                        sliderInput('ncol', 'Columns', min=1, max=3, value=2)
                  ),
                  mainPanel(
                        uiOutput('plots')
                  )
            )
      )
)

server <- shinyServer(function(input, output) {
      output$plots <- renderUI({
            makePlotContainers(input$nplots, ncol=input$ncol, height=input$height, width=input$width)
      })
      observeEvent(input$nplots, renderPlots(input$nplots, input, output))
})

shinyApp(ui, server)
