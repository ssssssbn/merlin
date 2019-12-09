#!/bin/sh

cd $(dirname $0)/
./cfddns_run.sh stop

rm -rf /koolshare/res/icon-cfddns.png > /dev/null 2>&1
rm -rf /koolshare/res/cfddns_log.htm > /dev/null 2>&1
rm -rf /koolshare/res/cfddns_status.htm > /dev/null 2>&1
rm -rf /koolshare/webs/Module_cfddns.asp > /dev/null 2>&1
rm -rf /koolshare/scripts/cfddns.sh > /dev/null 2>&1
rm -rf /koolshare/scripts/cfddns_run.sh > /dev/null 2>&1
rm -rf /koolshare/scripts/cfddns_status.sh > /dev/null 2>&1
rm -rf /koolshare/scripts/uninstall_cfddns.sh > /dev/null 2>&1

dbus remove __delay__cfddns_timer
dbus remove softcenter_module_cfddns_install
dbus remove softcenter_module_cfddns_version
dbus remove softcenter_module_cfddns_description