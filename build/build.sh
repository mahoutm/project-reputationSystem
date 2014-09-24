cd ..
. etc/env.inc
cd build
javac *.java
jar cf mahoutNB-tools.jar *.class
cp mahoutNB-tools.jar ../lib

