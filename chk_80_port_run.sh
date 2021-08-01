#!/bin/bash
#VPN_HOME="/home/roid/vpn"
VPN_HOME="/home/vpn"
if [ "$USER" != "root" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi
netstat -ntpl | grep LISTEN | grep [0-9:]:${1:-80}" " -q ; 
IS_EXIST80=$?
netstat -ntpl | grep java | grep LISTEN | grep [0-9:]:${1:-80}" " -q ; 
IS_JAVA80=$?
if [ $IS_EXIST80 -eq 0 ] ; then
	if [ $IS_JAVA80 -eq 0 ] ; then
		netstat -ntpl | grep java | grep LISTEN | grep [0-9:]:${1:-80}" "
		echo "VPN Client already running !!"
		exit 0
	else
		netstat -ntpl | grep LISTEN | grep [0-9:]:${1:-80}" "
		echo "80 port already used by other process !!"
		exit 1
	fi
fi
CUR_DIR=`pwd`
cd $VPN_HOME
ps aux | grep java | grep vpn-client.jar | awk '{print $2}' | xargs kill 2>/dev/null
sleep 1
nohup java -jar vpn-client.jar client.conf >/dev/null 2>&1 &
cd $CUR_DIR
ps -ef | grep java | grep vpn-client.jar
exit 0
