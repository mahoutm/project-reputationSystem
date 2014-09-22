import psycopg2

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
cur.execute("select * from water_korea_dump where rep is null") 

# input your opinion to docuemnts. 
for rec in cur:
	seq, target, num, link, body, rep = rec
	print (body)
	var = raw_input("Please your decision (1:good or 2:bad) : ")
	stack[str(seq)] = 'Good' if int(var) == 1 else 'Bad'

# update reputation field.
for seq in stack.keys():
	stmt = "update water_korea_dump set rep = '" + stack[seq] + "' where seq = " + seq
	print stmt
	cur.execute(stmt)

conn.commit()
conn.close()
