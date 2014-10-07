library(shiny)
library(RPostgreSQL)
library(ggplot2)
library(grid)
library(gridExtra)
library(KoNLP)
library(RColorBrewer)
library(wordcloud)

# Define server logic required to generate and plot a random distribution
shinyServer(function(input, output) {
  
  # Expression that generates a plot of the distribution. The expression
  # is wrapped in a call to renderPlot to indicate that:
  #
  #  1) It is "reactive" and therefore should be automatically 
  #     re-executed when inputs change
  #  2) Its output type is a plot 
  #

  output$status <- renderText({"상승"})
  output$explain <- renderText({"현재 평판 측정치는 최근 1개월간의 평균값 이상이며,향후 1주일간 상승이 예상 됩니다!!"})
  output$code <- renderUI({ 

    bins <- 7
    drv <- dbDriver("PostgreSQL")
    con <- dbConnect(drv, dbname="uzeni",host="192.168.50.170",port=5432,user="postgres",password="pw")
    rep_sum <- dbGetQuery(con,paste("
                                    SELECT to_timestamp(tm,'YYYYMMDDHH24') as tm
                                    ,good_cnt as good 
                                    ,bad_cnt as bad
                                    FROM (
                                    SELECT
                                    substr(gettm,1,10) as tm
                                    ,sum(good_cnt) as good_cnt
                                    ,sum(bad_cnt) as bad_cnt
                                    FROM water_korea_test_sum
                                    WHERE gettm between to_char(now() - '",bins," days'::interval, 'YYYYMMDDHH24MI') AND to_char(now() - '1 hours'::interval, 'YYYYMMDDHH24MI')
                                    GROUP BY substr(gettm,1,10)
                                    ORDER BY substr(gettm,1,10) ASC ) A",sep=""))
    
    dbDisconnect(con)
    
    x <- rep_sum$tm
    # fix reputation values belong -5 and 5.
    y <- ( rep_sum$good / ( rep_sum$good + rep_sum$bad ) - 0.5 ) * 10
    
    xx <- x ; div <- length(x)
    zz <- 1 ; zz[1:div] <- '평균'
    for (i in 1:7) {xx[div + i] <- max(x) + ( 3600 * (i)) ; zz[div + i] <- '예측' }
    
    m <- lm(y ~ poly(x,3))
    yy <- predict(m,newdata=data.frame(x=xx),interval = "confidence")
    yy <- data.frame(yy)
    
    # description about standard values
    desc.slope <- 0.15; desc.lev <- 1
    desc.cond = yy$fit[div] - mean(yy$fit[div - 7:div])

    if ( desc.cond < 0 ) out.cond <- '미만' else out.cond <- '이상'
    lev <- yy$fit[div]
    if ( lev  > desc.lev  )            		out.color <- 'green'
    if ( lev < desc.lev && div > - desc.lev )  	out.color <- 'blue'
    if ( lev < - desc.lev )             	out.color <- 'red'
    slope <- yy$fit[div + 7] - yy$fit[div]
    if ( slope > desc.slope  )                   	out.text  <- '상승'
    if ( slope < desc.slope && slope > - desc.slope )   out.text  <- '유지'
    if ( slope < - desc.slope )                   	out.text  <- '하락'
    out.style <- paste("color:",out.color,sep="")
    out.text2 <- paste("현재 평판 측정치는 최근 1주일간의 평균값 ",out.cond,"이며,향후 1주일간 ",out.text," 예상 됩니다!!",seq="")
    
  fluidRow(
  	column(5, wellPanel (h1(out.text, style = out.style , align = "center"))) 
  	,
  	column(7, h4(out.text2,align = "center"))
  )

    	}) 
    
  output$PlotA <- renderPlot({
    
    bins <- input$bins
    
    drv <- dbDriver("PostgreSQL")
    con <- dbConnect(drv, dbname="uzeni",host="192.168.50.170",port=5432,user="postgres",password="pw")
    rep_sum <- dbGetQuery(con,paste("
                                    SELECT to_timestamp(tm,'YYYYMMDDHH24') as tm
                                    ,good_cnt as good 
                                    ,bad_cnt as bad
                                    FROM (
                                    SELECT
                                    substr(gettm,1,10) as tm
                                    ,sum(good_cnt) as good_cnt
                                    ,sum(bad_cnt) as bad_cnt
                                    FROM water_korea_test_sum
                                    WHERE gettm between to_char(now() - '",bins," days'::interval, 'YYYYMMDDHH24MI') AND to_char(now() - '1 hours'::interval, 'YYYYMMDDHH24MI')
                                    GROUP BY substr(gettm,1,10)
                                    ORDER BY substr(gettm,1,10) ASC ) A",sep=""))
    
    dbDisconnect(con)
    
    
    p1 <-
      qplot(x=tm,y=good,data=rep_sum,main='긍정 Counts',xlab='',ylab='counts') +
      geom_smooth() +
      #geom_point(shape = 21, colour='purple',size=2) +
      geom_line(linetype='dashed', colour='purple',size=0.2)  
    
    p2 <-
      qplot(x=tm,y=bad,data=rep_sum,main='부정 Counts',xlab='',ylab='counts') +
      geom_smooth() +
      #geom_point(shape = 21, colour='red',size=2) +
      geom_line(linetype='dashed', colour='red',size=0.2)
    
    grid.arrange(p1, p2, ncol = 2, main = "한국수력원자력(주)")
    
  })
  
  output$PlotB <- renderPlot({

    bins <- input$bins
    
    drv <- dbDriver("PostgreSQL")
    con <- dbConnect(drv, dbname="uzeni",host="192.168.50.170",port=5432,user="postgres",password="pw")
    rep_sum <- dbGetQuery(con,paste("
                                    SELECT to_timestamp(tm,'YYYYMMDDHH24') as tm
                                    ,good_cnt as good 
                                    ,bad_cnt as bad
                                    FROM (
                                    SELECT
                                    substr(gettm,1,10) as tm
                                    ,sum(good_cnt) as good_cnt
                                    ,sum(bad_cnt) as bad_cnt
                                    FROM water_korea_test_sum
                                    WHERE gettm between to_char(now() - '",bins," days'::interval, 'YYYYMMDDHH24MI') AND to_char(now() - '1 hours'::interval, 'YYYYMMDDHH24MI')
                                    GROUP BY substr(gettm,1,10)
                                    ORDER BY substr(gettm,1,10) ASC ) A",sep=""))

    dbDisconnect(con)

    x <- rep_sum$tm
    # fix reputation values belong -5 and 5.
    y <- ( rep_sum$good / ( rep_sum$good + rep_sum$bad ) - 0.5 ) * 10

    xx <- x ; div <- length(x)
    zz <- 1 ; zz[1:div] <- '평균'
    for (i in 1:10) {xx[div + i] <- max(x) + ( 3600 * (i)) ; zz[div + i] <- '예측' }

    m <- lm(y ~ poly(x,3))
    yy <- predict(m,newdata=data.frame(x=xx),interval = "confidence")
    yy <- data.frame(yy)

    qplot(title='평판 트랜드',xlab='',ylab='평판지수',ylim=c(-5,5)) +
    geom_hline(yintercept=0,colour='black',alpha=0.5) +
    #geom_smooth(aes(x,y)) +
    geom_point(aes(x, y), shape=21, colour='black', fill='purple',size=2) + 
    geom_line(aes(xx, yy$fit, linestyle='dashed',colour=factor(zz)) ,size=3,alpha=0.7)

  })
  
  output$PlotC <- renderPlot({

    drv <- dbDriver("PostgreSQL")
    con <- dbConnect(drv, dbname="uzeni",host="192.168.50.170",port=5432,user="postgres",password="pw")
    wc <- dbGetQuery(con,"select word,count from mecab_nn_wc where length(word) > 1;")
    dbDisconnect(con)
    pal <- brewer.pal(12,"Set3")
    pal <- pal[-c(1:2)]
    par(family="AppleGothic")
    wordcloud(words=wc$word,freq=wc$count,scale=c(6,0.3),max.words=50,
              random.order=F,rot.per=.1,colors=pal)
  })

  output$table <- renderDataTable({

    bins <- 1
    
    drv <- dbDriver("PostgreSQL")
    con <- dbConnect(drv, dbname="uzeni",host="192.168.50.170",port=5432,user="postgres",password="pw")
    rep_data <- dbGetQuery(con,paste("
                                    SELECT
                                    to_timestamp(substr(gettm,1,10),  'YYYYMMDDHH24')as Get_Time
                                    ,doctm as Upload_Time
                                    ,target as Reference
                                    ,num
                                    ,substr(link,1,30) as URL
                                    ,substr(body,1,50) as Contents
                                    ,rep as Reputation
                                    FROM water_korea_test
                                    WHERE gettm between to_char(now() - '",bins," days'::interval, 'YYYYMMDDHH24MI') AND to_char(now() - '1 hours'::interval, 'YYYYMMDDHH24MI')"
                                    ,sep=""))
    
    dbDisconnect(con)
    rep_data
  })

})
