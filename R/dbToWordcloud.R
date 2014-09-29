library("RPostgreSQL")
library("tm")
library("wordcloud")

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="uzeni",host="192.168.50.170",port=5432,user="postgres",password="pw")

# take a vector (word, count)
word_vec <- dbGetQuery(con,"select word, count(*) from mecab_stack 
where 
  length(word) > 1 
  and opt like 'NNG%' 
group by word 
order by count(*) desc")

#Encoding(word_vec$word) <- "UTF-8"

wordcloud(word_vec$word,word_vec$count, scale=c(5,0.5), max.words=10, random.order=FALSE,
          rot.per=0.35, use.r.layout=FALSE, colors=brewer.pal(8, "Dark2"))

