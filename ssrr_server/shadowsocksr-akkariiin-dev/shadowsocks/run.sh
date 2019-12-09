#!/bin/sh
cd $(dirname $0)/
ulimit -HSn 65536
nohup python server.py a >> /dev/null 2>&1 &

