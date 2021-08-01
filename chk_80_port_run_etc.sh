#!/bin/bash
YT_ID="roid"
#YT_HOME="/home/roid/"
YT_HOME="/home/ytcapi"
if [ "$USER" != "$YT_ID" ]; then
	echo "This script must be run as $YT_ID" 1>&2
	exit 1
fi
netstat -ntpl 2>/dev/null | grep LISTEN | grep [0-9:]:${1:-9090}" " -q ; 
IS_EXIST9090=$?
CHK_PS=`netstat -ntpl 2>/dev/null | grep LISTEN | awk '/:9090 */ {split($NF,a,"/"); print a[1]}'` ; 
ps -ef | grep java | grep YTCAPI.jar | awk '{print $2}' | grep ${1:-$CHK_PS} -q 2>/dev/null ; 
IS_YT9090=$?
if [ $IS_EXIST9090 -eq 0 ] ; then
	if [ $IS_YT9090 -eq 0 ] ; then
		ps -ef | grep java | grep YTCAPI.jar
		echo "YTCAPI already running !!"
		exit 0
	else
		netstat -ntpl 2>/dev/null | grep LISTEN | grep [0-9:]:${1:-9090}" "
		echo "9090 port already used by other process !!"
		exit 1
	fi
else
	ps -ef | grep YTCAPISS.jar | grep ${1:-java} -q 2>/dev/null ; 
	if [ $? -eq 0 ] ; then
		ps -ef | grep java | grep YTCAPI.jar
		echo "YTCAPI already running !! Wait a second for port listen !!"
		exit 0
	fi
fi
CUR_DIR=`pwd`
ps aux | grep java | grep YTCAPI.jar | awk '{print $2}' | xargs kill 2>/dev/null
export TSA_URL=http://ca.yt.uz/tst
export TRUSTSTORE_FILE=$YT_HOME/keys/truststore.jks
export TRUSTSTORE_PASSWORD=00000000
sleep 1
cd $YT_HOME
nohup java -Dfile.encoding=UTF-8 -Djava.ext.dirs=lib -jar YTCAPI.jar -p 9090 >/dev/null 2>&1 &
cd $CUR_DIR
ps -ef | grep java | grep YTCAPI.jar
exit 0
