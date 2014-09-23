#!/usr/bin/python

import psycopg2

var = raw_input("WHO ARE YOU ? (JERRY:0 ,RED:1 ,DAVE:2 ,MARK:3) ")
X = var  

# http://pythonhosted.org/psycopg2/
# connect to db
try:
    conn = psycopg2.connect("dbname='uzeni' user='postgres' host='192.168.50.170' password='trust'")
    #conn = psycopg2.connect("dbname='Mark' user='Mark' host='localhost' password=''")
except:
    print "I am unable to connect to the database"

stack = {}

# open cursor
cur = conn.cursor()
cur.execute("select * from water_korea_train") 

# input your opinion to docuemnts. 
for rec in cur:
	seq, gettm, doctm, target, num, link, body, rep = rec
	if str(seq % 4) == X and rep == 'None':
		print (body)
		var = raw_input("Please your decision (1:None or others:Good ) : ")
		stack[str(seq)] = 'Good'
		if var == '1' : stack[str(seq)] = 'None'

# update reputation field.
for seq in stack.keys():
	stmt = "update water_korea_train set rep = '" + stack[seq] + "' where seq = " + seq
	print ('document ' + seq + ' have updated to ' + stack[seq] + '.')
	cur.execute(stmt)

conn.commit()
conn.close()
