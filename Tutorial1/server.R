library(dplyr)
library(lubridate)
library(BH)

library(dplyr)

taxiData <- read.csv("tripData.csv", stringsAsFactors = FALSE)
taxiDataSmall <- sample_frac(taxiData, 0.01)

taxiDataSmall$tpep_pickup_datetime <- ymd_hms(taxiDataSmall$tpep_pickup_datetime)

taxiDataSmall$Day <- wday(taxiDataSmall$tpep_pickup_datetime)

tripsPlot <- function(day, startHour, endHour) {
  tripsData <- subset(taxiDataSmall, Day == day)
  tripsTable <- table(hour(tripsData$tpep_pickup_datetime))
  tripsTable <- as.table(tripsTable[(startHour + 1):(endHour + 1)])
  taxiPlot <- plot(tripsTable, type = 'o', xlab = 'Hour', xlim = c(startHour, endHour))
  return(taxiPlot)
}

shinyServer(
  function(input, output) {
    output$day <- renderPrint({input$day})
    output$startHour <- renderPrint({input$startHour})
    output$endHour <- renderPrint({input$endHour})
    output$taxiPlot <- renderPlot({tripsPlot(input$day, input$startHour, input$endHour)})
  }
)

