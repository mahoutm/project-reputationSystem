#!/bin/bash
MAHOUT_HOME=/usr/lib/mahout
APP_HOME=/usr/lib/hue/rep
TABLE='water_korea_test'
SUM_TABLE='water_korea_test_sum'
PGSQL='psql -AtEq -h 192.168.50.170 -U postgres -d uzeni '


# Naive Bayes Classifier using mahout.
export CLASSPATH=$(hadoop classpath):$MAHOUT_HOME/mahout-examples-0.9.0.2.1.1.0-385-job.jar:$APP_HOME/lib/mahoutNB-tools.jar:$APP_HOME/lib/postgresql-9.3-1102.jdbc41.jar:$APP_HOME/lib:.
export JAVA_HOME=/usr

java PostgresClassifier /user/root/train/model /user/root/train/labelindex /user/root/train/vec/dictionary.file-0 /user/root/train/vec/df-count/part-r-00000 $TABLE

# List up
$PGSQL <<EOF
INSERT INTO $SUM_TABLE (gettm)
SELECT A.gettm FROM 
	(SELECT gettm FROM $TABLE GROUP BY gettm ) A
	LEFT JOIN
	(SELECT gettm FROM $SUM_TABLE GROUP BY gettm ) B
	ON A.gettm = B.gettm
	WHERE B.gettm IS NULL;
EOF

# Make Summary Table.	
# Rep count up
$PGSQL <<EOF | $PGSQL
SELECT
	'update $SUM_TABLE set '|| rep ||'_cnt = '|| count ||' where gettm::bigint = '|| gettm ||';'
FROM (
	SELECT gettm::bigint, rep, count(*)
	FROM $TABLE WHERE gettm::bigint > to_char(now() - '3 days'::interval,'YYYYMMDDHH24MI')::bigint
	GROUP BY gettm, rep
) M;
EOF

# sum up 
$PGSQL <<EOF 
UPDATE $SUM_TABLE
	SET all_cnt = good_cnt + bad_cnt + none_cnt
	WHERE all_cnt = 0;
EOF

