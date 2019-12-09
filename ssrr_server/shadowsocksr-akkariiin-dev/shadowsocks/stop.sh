#!/bin/sh
pid=`ps|grep "server.py a"|grep -v grep|awk '{print $1}'`
if [ -n "$pid" ]; then
echo kill \"server.py a\" pid $pid
	kill $pid
else
echo "server.py a" is not running
fi