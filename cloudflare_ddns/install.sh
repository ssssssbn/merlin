#!/bin/sh
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'

# 关闭插件先
enable=`dbus get cfddns_enable`
if [ "$enable" == "1" ];then
	echo_date 检测到在启动
	dbus set cfddns_enable=0
	echo_date 关闭V2ray
	/koolshare/scripts/cfddns_run.sh stop
fi

echo_date 复制文件中----文件较大请耐心等待
cp -rf /tmp/cfddns/scripts/* /koolshare/scripts/
cp -rf /tmp/cfddns/web/* /koolshare/webs/
cp -rf /tmp/cfddns/res/* /koolshare/res/

echo_date 删除安装包
rm -rf /tmp/cfddns* >/dev/null 2>&1

echo_date 授予运行权限
chmod 777 /koolshare/scripts/cfddns.sh
chmod 777 /koolshare/scripts/cfddns_run.sh
chmod 777 /koolshare/scripts/uninstall_cfddns.sh

dbus set softcenter_module_cfddns_install=1
dbus set softcenter_module_cfddns_version=1.3
dbus set cfddns_version=1.3
dbus set softcenter_module_cfddns_description="CloudFlare DDNS插件"