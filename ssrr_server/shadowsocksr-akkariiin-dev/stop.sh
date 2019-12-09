#!/bin/sh
eval $(ps|grep "server.py m"|grep -v grep|awk '{print "kill "$1}')