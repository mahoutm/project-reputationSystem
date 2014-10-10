#!/bin/bash

# DB INFO.
DB_HOST='192.168.50.170'
DB_USR='postgres'
DB_NAME='uzeni'

# LOCAL INFO.
TABLE_NAME='water_korea_test_sum'
SQL_FILE='/tmp/'${TABLE_NAME}'.sql'
TAR_FILE=${SQL_FILE}'.tgz'

/usr/bin/pg_dump -h $DB_HOST -U $DB_USR -t $TABLE_NAME $DB_NAME  > $SQL_FILE && tar -czf $TAR_FILE $SQL_FILE && hadoop fs -mkdir $1 && hadoop fs -put $TAR_FILE $1

rm -f $SQL_FILE
rm -f $TAR_FILE
