library(shiny)

# Define UI for dataset viewer application
shinyUI(navbarPage("UZENi Reputation Monitor", id="nav",

  tabPanel("대시보드",
    fluidRow(
      column(12, h5("인터넷상에서 키워드 및 연관어 검색을 통하여 평판을 수집하여, 긍.부정 현황과 트랜드 정보를 제공 합니다!"))
    ),
  
    hr(),
    uiOutput("code"),

    fluidRow(
      p("* 글자색 : ",
        span("빨간색", style = "color:red"),
        " - 평판이 평균 이하, ",
        span("파란색", style = "color:blue"),
        " - 평판이 평균에 근접, ",
        span("초록색", style = "color:green"),
        " - 평판이 평균 이상"
      ),
      p("* 글자내용 : ",
        strong("상승"),
        " - 평판이 좋아지고 있음, ",
        strong("유지"), 
        " - 평판이 현상태를 유지함, ", 
        strong("하락"), 
        " - 평판이 나빠지고 있음")
    ),
    hr(),
  
    fluidRow(
      h4("기간선택:"),
      sliderInput("bins",
                "출력일수(day): ",
                min = 1,
                max = 30,
                value = 7)
    ),
    fluidRow(
      column(7,
           plotOutput("PlotB")
      ),
      column(5,
           plotOutput("PlotC")
      )
    ),
    fluidRow(
      column(12,
           plotOutput("PlotA")
      )
    )
  ),  
  
  tabPanel("데이터 조회",
    hr(),
  
    fluidRow(
      dataTableOutput(outputId="table")
    )    
  ),

  conditionalPanel("false", icon("crosshair"))
))

