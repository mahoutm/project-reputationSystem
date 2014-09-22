MAHOUT_HOME=/usr/lib/mahout
APP_HOME=$(pwd)

export CLASSPATH=$(hadoop classpath):$MAHOUT_HOME/mahout-examples-0.9.0.2.1.1.0-385-job.jar:$APP_HOME/lib/mahoutNB-tools.jar:$APP_HOME/lib/postgresql-9.3-1102.jdbc41.jar:$APP_HOME/lib:.

