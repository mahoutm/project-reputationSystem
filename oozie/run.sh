#!/bin/bash
MAHOUT_HOME=/usr/lib/mahout
APP_HOME=/usr/lib/hue/rep
TABLE='water_korea_test'

export CLASSPATH=$(hadoop classpath):$MAHOUT_HOME/mahout-examples-0.9.0.2.1.1.0-385-job.jar:$APP_HOME/lib/mahoutNB-tools.jar:$APP_HOME/lib/postgresql-9.3-1102.jdbc41.jar:$APP_HOME/lib:.
export JAVA_HOME=/usr

java PostgresClassifier /user/root/train/model /user/root/train/labelindex /user/root/train/vec/dictionary.file-0 /user/root/train/vec/df-count/part-r-00000 $TABLE
