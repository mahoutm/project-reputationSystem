library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("Smile with Water Korea"),


fluidRow(
	h4("input area"),
        sliderInput("bins",
                    "Start ago (day): ",
                    min = 1,
                    max = 30,
                    value = 7)
)
,
fluidRow(
	column(8,
		plotOutput("PlotB")
	),
	column(4,
		plotOutput("PlotC")
	)
)
,
fluidRow(
	column(12,
	plotOutput("PlotA")
))
))

