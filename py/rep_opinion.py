import psycopg2

try:
    conn = psycopg2.connect("dbname='uzeni' user='postgres' host='192.168.50.188' password='dbwpsdkdl'")
except:
    print "I am unable to connect to the database"

stack = {}

cur = conn.cursor()
cur.execute("select * from water_korea_dump;")
for rec in cur:
	seq, target, num, link, value, yn = rec
	print (value)
	var = raw_input("Please your decision (1:good or 2:bad) : ")
	stack[seq]=yn

for str in stack:
	print (str.value)

conn.commit()
conn.close()
