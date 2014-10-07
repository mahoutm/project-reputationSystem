#!/bin/bash

python <<EOF
import psycopg2
import MeCab as mc
import re

m = mc.Tagger('-d /usr/local/lib/mecab/dic/mecab-ko-dic')

# Connect to postgresql
try:
    conn = psycopg2.connect("dbname='uzeni' user='postgres' host='192.168.50.170' password='pw'")
except:
    print "I am unable to connect to the database"

# Open query and insert cursor
cur = conn.cursor()
cur2 = conn.cursor()
cur.execute("select * from water_korea_test where gettm > to_char(now() - '1 days'::interval,'YYYYMMDDHH24MI') limit 1000;")
cur2.execute("truncate mecab_nn_wc;")

wordcount={}
for rec in cur:
	seq, gettm, doctm, target, num, link, body, rep = rec
	dic = m.parse(body)
	num = 0
	for line in dic.splitlines():
		stack = line.split('\t')
		# fiter unfitted line
		if len(stack) < 2 : continue
		word = stack[0]; opt = stack[1] ; num += 1
		if bool(re.match('NN.+',opt)):
              		if word not in wordcount:
				wordcount[word] = 1
			else:
				wordcount[word] += 1

for word in wordcount:
	cur2.execute("insert into mecab_nn_wc (word,count) values ('"+word+"',"+str(wordcount[word])+");")

conn.commit()
conn.close()
EOF
