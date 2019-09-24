library(shiny)
library(ggvis)

shinyUI(fluidPage(
     
     # Application title
     titlePanel("Control chart simulation"),
     
     # Sidebar with a slider input for the number of bins
     sidebarLayout(
          sidebarPanel(
               sliderInput("n",
                           "Number of samples per month:",
                           min = 1,
                           max = 200,
                           value = 30),
               sliderInput("reps",
                           "Number of sites to show in control chart:",
                           min = 1,
                           max = 25,
                           value = 1),
               sliderInput("m",
                           "Number of months to show:",
                           min = 12,
                           max = 48,
                           value = 24),
               numericInput("p",
                            "True defect rate (which of course is unknown in the real world)",
                            min = 0, max = 1, step = 0.01,
                            value = 0.15),
               numericInput("thresh",
                            "Target maximum defect rate",
                            min = 0, max = 1, step = 0.01,
                            value = 0.10),
               p(
                    "This is a simulation of a quality control exercise across multiple sites for
                    12 to 60 months where defect is a binary attribute.  Choose the parameters 
                    above to see the impact of different 
                    sample size, number of sites, true defect rate, etc.  It is assumed
                    that the true defect rate does not change over time or between sites."),
               HTML(
                    "<p>The top chart is what 'Six Sigma' practitioners call
                    <a href = 'http://www.isixsigma.com/tools-templates/control-charts/a-guide-to-control-charts/'>
                    a p-control chart</a>.  The horizontal black dashed line shows the level
                    above which we will be confident, in any one month, that the true defect rate 
                    exceeds the maximum acceptable target; that is, it is three standard deviations
                    higher than the target rate.  The target rate itself is shown by the horizontal
                    solid black line.  Each coloured line (one or more of them) represents the observed defect rate
                    for an individual site.  The aim is to give the user an idea of what you would
                    be presented with for control charts with a given sample size.</p>"    
               ),
               p("The second chart shows the result of the cumulative collection of data and
                 is aimed at forming the best estimate of the true defect rate at a particular site,
                 assuming it doesn't change over time. 
                 As more data accumulates over time, the confidence interval estimated for the 
                 true defect rate gets narrower and converges to the actual defect rate."),
               
               p("One point this simulation illustrates is that large sample sizes are needed
                 each month if you wish to confidently identify faulty sites in any particular month; but
                 drawing conclusions over a longer period is more reliable - so long as defect
                 rates really are fairly stable over time in particular sites."),
               p("A second point we illustrate is that even when the true defect rate is
                 higher than the target there will be many samples that do not exceed
                 the the 'three standard deviations' warning point; and even when the true 
                 defect rate is lower than the target there will occasionally be times when
                 an individual month-site combination is above the warning point due to chance.")
               ),
          
          # Show a plot of the generated distribution
          mainPanel(
               h3("Example control chart/s - one line per site"),
               ggvisOutput("controlChart"),
               h3("A single site's narrowing confidence interval for defect rate"),
               ggvisOutput("ribbonChart")
          )
               )
               ))
