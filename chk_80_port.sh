#!/bin/bash
netstat -ntpl | grep LISTEN | grep [0-9:]:${1:-80}" " -q ; 
IS_EXIST80=$?
netstat -ntpl | grep java | grep LISTEN | grep [0-9:]:${1:-80}" " -q ; 
IS_JAVA80=$?
if [ $IS_EXIST80 -eq 0 ] ; then
	if [ $IS_JAVA80 -eq 0 ] ; then
		netstat -ntpl | grep java | grep LISTEN | grep [0-9:]:${1:-80}" "
		echo "Java Running !!"
		exit 0
	else
		netstat -ntpl | grep LISTEN | grep [0-9:]:${1:-80}" "
		echo "[ERROR!!!] : 80 port already used by other process !!"
		exit 1
	fi
else 
	echo "no 80 port used !!"
fi
