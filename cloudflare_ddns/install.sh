#!/bin/sh
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'
web_version=1.4
script_version=1.4
installed=`dbus get softcenter_module_cfddns_install`
if [ $installed -eq 1 ];then
	installed_web_version=`dbus get softcenter_module_cfddns_version`
	installed_script_version=`dbus get cfddns_version`
	if [ $installed_web_version -le $web_version -a $installed_script_version -le $script_version ];then
		echo_date 'CFDDNS插件已为最新版本'
		exit 0
	fi
	# 关闭插件先
	enable=`dbus get cfddns_enable`
	if [ "$enable" == "true" ];then
		echo_date '检测到CFDDNS已启动'
		dbus set cfddns_enable=false
		echo_date '停止CFDDNS'
		/koolshare/scripts/cfddns_run.sh
	fi
	echo_date '正在卸载旧版本'
	/koolshare/scripts/uninstall_cfddns.sh
	echo_date '完成卸载旧版本'
fi


echo_date '复制文件中'
cp -rf /tmp/cfddns/scripts/* /koolshare/scripts/
cp -rf /tmp/cfddns/web/* /koolshare/webs/
cp -rf /tmp/cfddns/res/* /koolshare/res/

echo_date '删除安装包'
rm -rf /tmp/cfddns* >/dev/null 2>&1

echo_date 授予运行权限
chmod 777 /koolshare/scripts/cfddns.sh
chmod 777 /koolshare/scripts/cfddns_run.sh
chmod 777 /koolshare/scripts/cfddns_status.sh
chmod 777 /koolshare/scripts/uninstall_cfddns.sh

dbus set cfddns_version=$script_version
dbus set softcenter_module_cfddns_install=1
dbus set softcenter_module_cfddns_version=$web_version
dbus set softcenter_module_cfddns_description="CloudFlare DDNS插件"