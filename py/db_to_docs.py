import psycopg2

# http://pythonhosted.org/psycopg2/
# connect to db
try:
    #conn = psycopg2.connect("dbname='uzeni' user='postgres' host='192.168.50.188' password='dbwpsdkdl'")
    conn = psycopg2.connect("dbname='Mark' user='Mark' host='localhost' password=''")
except:
    print "I am unable to connect to the database"

stack = {}

# open cursor
cur = conn.cursor()
cur.execute("select * from water_korea_dump where rep is null") 


# write to docs
f = 
for rec in cur:
	seq, target, num, link, body, rep = rec

conn.commit()
conn.close()
