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
cur.execute("select * from water_korea_test where rep is not null and gettm > to_char(now() - '1 hours'::interval,'YYYYMMDDHH24MI');")
#cur2.execute("delete from mecab_nn_wd where tm < to_char(now() - '7 days'::interval,'YYYYMMDDHH24MI');")

wc_good={}
wc_bad={}
wc_none={}
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
			if rep == 'Good':
		       		if word not in wc_good :
					wc_good[word] = 1
				else:
					wc_good[word] += 1
			if rep == 'Bad':
		       		if word not in wc_bad :
					wc_bad[word] = 1
				else:
					wc_bad[word] += 1
			if rep == 'None':
		       		if word not in wc_none :
					wc_none[word] = 1
				else:
					wc_none[word] += 1

for word in wc_good:
	cur2.execute("insert into mecab_nn_wc (tm,rep,word,count) values (now(),'Good','"+word+"',"+str(wc_good[word])+");")
for word in wc_bad:
	cur2.execute("insert into mecab_nn_wc (tm,rep,word,count) values (now(),'Bad','"+word+"',"+str(wc_bad[word])+");")
for word in wc_none:
	cur2.execute("insert into mecab_nn_wc (tm,rep,word,count) values (now(),'None','"+word+"',"+str(wc_none[word])+");")

conn.commit()
conn.close()
EOF
