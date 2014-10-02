library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="uzeni",host="192.168.50.170",port=5432,user="postgres",password="pw")
rep_sum <- dbGetQuery(con,"
                      SELECT to_timestamp(tm,'YYYYMMDDHH24') as tm
                      ,good_cnt * 10. / all_cnt as good
                      ,bad_cnt * 10. / all_cnt as bad
                      ,none_cnt * 10. / all_cnt as none
                      FROM (
                      SELECT
                      substr(gettm,1,10) as tm
                      ,sum(good_cnt) as good_cnt
                      ,sum(bad_cnt) as bad_cnt
                      ,sum(none_cnt) as none_cnt
                      ,sum(all_cnt) as all_cnt
                      FROM water_korea_test_sum
                      WHERE gettm between '201410010000' AND '201410021100'
                      GROUP BY substr(gettm,1,10)
                      ORDER BY substr(gettm,1,10) ASC ) A")

# for using sample data set.
#library(csv)
#write.csv(rep_sum,file="data/rep_sum.rdata")
#read.csv(file="data/rep_sum.rdata")

library(ggplot2)
library(grid)
library(gridExtra)

x <- rep_sum$tm
y <- rep_sum$good

p1 <-
  qplot(x=tm,y=good,data=rep_sum,geom=c("smooth"),mothod='lm',formula=y~x,main='Good chart',xlab='datetime',ylab='reputaion') +
  geom_line(linetype='dashed', colour='blue',size=0.1) +
  geom_point(shape = 24,fill='blue',size=5)

p2 <-
  qplot(x=tm,y=bad,data=rep_sum,geom=c("smooth"),main='Bad chart',xlab='datetime',ylab='reputaion') +
  geom_line(linetype='dashed', colour='red',size=0.1) +
  geom_point(shape = 25,fill='red',size=5)

p3 <-
  qplot(x=tm,y=none,data=rep_sum,geom=c("smooth"),main='None chart',xlab='datetime',ylab='reputaion') +
  geom_line(linetype='dashed', colour='yellow',size=0.1) +
  geom_point(shape = 21,fill='yellow',size=5)

xx <- x
last <- length(xx)
zz <- 1
zz[1:last] <- 'Mean'

for (i in 1:3) {xx[last + i] <- max(x) + ( 3600 * (i)) ; zz[last + i] <- 'Predict' }

m <- lm(good ~ poly(tm,3), data=rep_sum,)
yy <- predict(m,newdata=data.frame(tm=xx)) #,interval = "confidence")

p4 <-
  qplot(xx, yy, geom = c("point","line"),col=factor(zz),main='Predicted Good chart',xlab='datetime',ylab='reputaion') +
  geom_point(shape = 21,size=5)

grid.arrange(p1, p2, p3, p4, nrow = 2, main = "Water Korea")



