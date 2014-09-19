. ../etc/env.inc
cp ../include/*.java ./
javac *.java
jar cf mahoutNB-tools *.class
cp mahoutNB-tools ../lib
