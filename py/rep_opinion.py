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
cur.execute("select * from water_korea_train where rep is null") 

# input your opinion to docuemnts. 
for rec in cur:
	seq, gettm, doctm, target, num, link, body, rep = rec
	if str(seq % 4) == X :
		print (body)
		var = raw_input("Please your decision (1:good or 2:bad or others:None) : ")
		stack[str(seq)] = 'Good' if var == '1' else 'Bad'

# update reputation field.
for seq in stack.keys():
	stmt = "update water_korea_train set rep = '" + stack[seq] + "' where seq = " + seq
	print ('document ' + seq + ' have updated to ' + stack[seq] + '.')
	cur.execute(stmt)

conn.commit()
conn.close()
