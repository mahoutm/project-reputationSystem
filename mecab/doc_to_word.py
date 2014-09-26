import psycopg2
import MeCab as mc

m = mc.Tagger('-d /usr/local/lib/mecab/dic/mecab-ko-dic')

# Connect to postgresql
try:
    conn = psycopg2.connect("dbname='uzeni' user='postgres' host='192.168.50.170' password='dbwpsdkdl'")
    #conn = psycopg2.connect("dbname='Mark' user='Mark' host='localhost' password=''")
except:
    print "I am unable to connect to the database"

# Open query and insert cursor
cur = conn.cursor()
cur2 = conn.cursor()
cur.execute("select * from water_korea_train limit 3") 

for rec in cur:
	seq, gettm, doctm, target, num, link, body, rep = rec
	dic = m.parse(body)
	num = 0
	for line in dic.splitlines():
		stack = line.split('\t')
		print (str(num) + stack[0])
		# fiter unfitted line
		if len(stack) < 2 : continue
		word = stack[0]; opt = stack[1] ; num += 1
		cur2.execute("insert into mecab_stack (doc_id,seq,word,opt) values ("+str(seq)+","+str(num)+",'"+word+"','"+opt+"')")

conn.commit()
conn.close()
