#!/usr/bin/python

import psycopg2

try:
    conn = psycopg2.connect("dbname='uzeni' user='postgres' host='192.168.50.170' password='trust'")
    #conn = psycopg2.connect("dbname='Mark' user='Mark' host='localhost' password=''")
except:
    print "I am unable to connect to the database"

# open cursor
cur = conn.cursor()
cur.execute("select * from water_korea_test_sum where gettm < '201409291510'") 

X = []
# input your opinion to docuemnts. 
for rec in cur:
	tm, good, bad, none, all = rec
	X.append([float(tm),float(good),float(bad),float(none),float(all)])

conn.commit()
conn.close()


