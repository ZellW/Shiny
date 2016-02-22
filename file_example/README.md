Download and install:

1. R
2. RStudio 

Download the dummy csv file from this gist ( https://gist.github.com/psychemedia/9690079 )

In RStudio run:

`install.packages("shiny")`

then

`library(shiny)`

followed by 

`runGist(9690079)`

An app should launch.

Load the downloaded dummy CSV file in (or another file of your own), choose the from, to, amount columns, then hit the Get Geodata button.

You should get a map with great circles connecting the points

TO DO - lots

- make the code R idiiomatic
- how to cope with missing amount column (?radio button to select amount Yes/No?) - DONE
- how to save map [DONE-ish - though it's clunky and not working way I wanted?]
- how to zoom map or limit display to particular area
- maybe allow support for different coloured lines? [Added different line views]
- directed lines/arrows?
- other geocoders (currently using Google)?
- other maps?
- etc etc