#!/bin/sh
cd $(dirname $0)/
./stop.sh
ulimit -HSn 65536
nohup python server.py a >> ssserver.log 2>&1 &