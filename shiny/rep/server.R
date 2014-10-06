library(shiny)
library("RPostgreSQL")
library(ggplot2)
library(grid)
library(gridExtra)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  # Expression that generates a histogram. The expression is
  # wrapped in a call to renderPlot to indicate that:
  #
  #  1) It is "reactive" and therefore should re-execute automatically
  #     when inputs change
  #  2) Its output type is a plot

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
  qplot(x=tm,y=good,data=rep_sum,main='Good chart',xlab='datetime',ylab='count') +
  geom_smooth() +
  #geom_point(shape = 21, colour='purple',size=2) +
  geom_line(linetype='dashed', colour='purple',size=0.2)  

p2 <-
  qplot(x=tm,y=bad,data=rep_sum,main='Bad chart',xlab='datetime',ylab='count') +
  geom_smooth() +
  #geom_point(shape = 21, colour='red',size=2) +
  geom_line(linetype='dashed', colour='red',size=0.2)

grid.arrange(p1, p2, ncol = 2, main = "Water Korea")

  })

  output$PlotB <- renderPlot({

bins <- input$bins

library("RPostgreSQL")

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
# for using sample data set.
#library(csv)
#write.csv(rep_sum,file="data/rep_sum.rdata")
#read.csv(file="data/rep_sum.rdata")

library(ggplot2)
library(grid)
library(gridExtra)

x <- rep_sum$tm
# fix reputation values belong -5 and 5.
y <- ( rep_sum$good / ( rep_sum$good + rep_sum$bad ) - 0.5 ) * 10

xx <- x ; div <- length(x)
zz <- 1 ; zz[1:div] <- 'Mean'
for (i in 1:10) {xx[div + i] <- max(x) + ( 3600 * (i)) ; zz[div + i] <- 'Predict' }

m <- lm(y ~ poly(x,3))
yy <- predict(m,newdata=data.frame(x=xx),interval = "confidence")
yy <- data.frame(yy)

qplot(title='Summary',xlab='time',ylab='reputation',ylim=c(-5,5)) +
  #geom_smooth(aes(x,y)) +
  geom_point(aes(x, y), shape=21, colour='black', fill='purple',size=2) + 
  geom_line(aes(xx, yy$fit, linestyle='dashed',colour=factor(zz) ,size=3,alpha=0.7))

  })
})
