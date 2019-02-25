library(shiny)
runApp("drinkr/shiny_app")

# shinytest requires a headless web browser (PhantomJS) to record and run tests.
# To install it, run shinytest::installDependencies()

library(shinytest)
recordTest("drinkr/shiny_app")


testApp("drinkr/shiny_app")
