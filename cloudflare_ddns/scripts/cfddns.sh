#!/bin/sh
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'
enable=`dbus get cfddns_enable`
cd $(dirname $0)/

rm -rf /tmp/cfddns_log.log
if [ "$enable" == "1" ];then
		echo_date 开启CFDDNS!!! >> /tmp/cfddns_log.log
		./cfddns_run.sh start
		echo_date 运行完毕!!! >> /tmp/cfddns_log.log
else
		echo_date 关闭CFDDNS >> /tmp/cfddns_log.log
		./cfddns_run.sh stop
		echo_date 运行完毕!!! >> /tmp/cfddns_log.log
fi