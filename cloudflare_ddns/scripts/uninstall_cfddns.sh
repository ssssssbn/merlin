#!/bin/sh
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'

# 关闭插件先
enable=`dbus get cfddns_enable`
if [ x"$enable" = x"true" ];then
	echo_date '检测到CFDDNS已启动'
	dbus set cfddns_enable=false
	echo_date '停止CFDDNS'
	/koolshare/scripts/cfddns_run.sh
fi

rm -rf /koolshare/res/icon-cfddns.png > /dev/null 2>&1
rm -rf /koolshare/res/cfddns_log.htm > /dev/null 2>&1
rm -rf /koolshare/res/cfddns_status.htm > /dev/null 2>&1
rm -rf /koolshare/webs/Module_cfddns.asp > /dev/null 2>&1
rm -rf /koolshare/scripts/cfddns.sh > /dev/null 2>&1
rm -rf /koolshare/scripts/cfddns_run.sh > /dev/null 2>&1
rm -rf /koolshare/scripts/cfddns_status.sh > /dev/null 2>&1
rm -rf /koolshare/scripts/uninstall_cfddns.sh > /dev/null 2>&1

#dbus remove __delay__cfddns_timer
dbus remove cfddns_version
dbus remove softcenter_module_cfddns_install
dbus remove softcenter_module_cfddns_version
dbus remove softcenter_module_cfddns_description