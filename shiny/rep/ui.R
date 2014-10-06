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
	mainPanel(
		plotOutput("PlotB")
	))
)
,
fluidRow(
	mainPanel(
		plotOutput("PlotA")
        )
)

))

