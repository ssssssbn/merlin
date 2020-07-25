#!/bin/sh
# 引用环境变量等
source /koolshare/scripts/base.sh

cd $(dirname $0)/

path=/koolshare/shadowsocksr-akkariiin-dev
pid=`ps|grep "server.py a"|grep -v grep|awk '{print $1}'`
#pid_watchdog=`ps|grep ssrr_server_watchdog.sh|grep -v grep|awk '{print $1}'`
ssrrserver_use_ss=1
preport=0
nextport=`jq -r .server_port $path/user-config.json`
#nextport=`cat $path/user-config.json|grep "server_port"|sed 's/\"server_port": //g'|sed 's/,//g'`
echo next $nextport
if [ -r $path/using-config.json ]; then
	preport=`jq -r .server_port $path/using-config.json`
	#preport=`cat $path/using-config.json|grep "server_port"|sed 's/\"server_port": //g'|sed 's/,//g'`
echo pre $preport
fi

ssrserver_start () {
echo start
	if [ x"$pid" != x"" ];then
echo ssr_server is running,pid=$pid
	else
		sh $path/shadowsocks/run.sh
		#python $path/shadowsocks/server.py -c $path/user-config.json >> /dev/null 2>&1 &
	
		cp $path/user-config.json $path/using-config.json
		pid=`ps|grep "server.py a"|grep -v grep|awk '{print $1}'`
	fi
}

ssrserver_stop () {
echo stop
	if [ x"$pid" == x"" ];then
echo ssr_server is not running
	else
		sh $path/shadowsocks/stop.sh
		if [ -e $path/using-config.json ]; then
			rm -rf $path/using-config.json
		fi
		pid=`ps|grep "server.py a"|grep -v grep|awk '{print $1}'`
	fi
}

auto_start(){
	if [ x"$1" == x"enable" ];then
		if [ ! -f /jffs/scripts/wan-start ]; then
			cat > /jffs/scripts/wan-start <<-EOF
				#!/bin/sh
				dbus fire onwanstart
			
				EOF
		fi
	
		startss=$(cat /jffs/scripts/wan-start | grep "/koolshare/scripts/ssrr_server.sh")
		if [ -z "$startss" ];then
			echo 添加wan-start触发事件...用于程序的开机启动...
			sed -i '2a sh /koolshare/scripts/ssrr_server.sh start &' /jffs/scripts/wan-start
			echo 成功添加wan-start触发事件
		fi
	elif [ x"$1" == x"disable" -a -f /jffs/scripts/wan-start ];then
		echo 删除开机启动
		sed -i '/ssrr_server.sh/d' /jffs/scripts/wan-start >/dev/null 2>&1
		echo 成功删除开机启动
	fi
}

ssrserver_check () {
echo check
	if [ -n "$pid" ]; then
		echo ssr_server is running,pid=$pid.
	else
		echo ssr_server is not running.
	fi
}

open_port(){
	if [ -n "$pid" ];then
		checkport=`iptables -nL|grep "tcp dpt:$nextport"`
		if [ -z "$checkport" ];then
			iptables -I INPUT -p tcp --dport $nextport -j ACCEPT >/dev/null 2>&1
		fi
		#checkport=`iptables -nL|grep "udp dpt:$nextport"`
		#if [ -z "$checkport" ];then
		#	iptables -I INPUT -p udp --dport $nextport -j ACCEPT >/dev/null 2>&1
		#fi
		checkport=`ip6tables -nL|grep "tcp dpt:$nextport"`
		if [ -z "$checkport" ];then
			ip6tables -I INPUT -p tcp --dport $nextport -j ACCEPT >/dev/null 2>&1
		fi
		#checkport=`ip6tables -nL|grep "udp dpt:$nextport"`
		#if [ -z "$checkport" ];then
		#	ip6tables -I INPUT -p udp --dport $nextport -j ACCEPT >/dev/null 2>&1
		#fi
	fi
}

close_port(){
	if [ 0 -ne $preport -a -z "$pid" ]; then
		checkport=`iptables -nL|grep dpt:$preport`
#echo checkport4 = $checkport
		while [ -n "$checkport" ]
		do
		# -t filter
			iptables -D INPUT -p tcp --dport $preport -j ACCEPT >/dev/null 2>&1
			#iptables -D INPUT -p udp --dport $preport -j ACCEPT >/dev/null 2>&1
			checkport=`iptables -nL|grep dpt:$preport`
#echo checkport4 = $checkport
		done
		checkport=`ip6tables -nL|grep dpt:$preport`
#echo checkport6 = $checkport
		while [ -n "$checkport" ]
		do
			ip6tables -D INPUT -p tcp --dport $preport -j ACCEPT >/dev/null 2>&1
			#ip6tables -D INPUT -p udp --dport $preport -j ACCEPT >/dev/null 2>&1
			checkport=`ip6tables -nL|grep dpt:$preport`
#echo checkport6 = $checkport
		done
	fi
}

write_nat_start(){
	if [ -z "`dbus listall | grep __event__onnatstart_ssrrserver`" ];then
		echo 添加nat-start触发事件...
		dbus set __event__onnatstart_ssrrserver="/koolshare/scripts/ssrr_server.sh"
	fi
}

remove_nat_start(){
	if [ -n "`dbus listall | grep __event__onnatstart_ssrrserver`" ];then
		echo 删除nat-start触发...
		dbus remove __event__onnatstart_ssrrserver
	fi
}

write_output(){
	if [ $ssrrserver_use_ss -eq 1 -a -n "$pid" ];then
		if [ ! -L "/jffs/configs/dnsmasq.d/gfwlist.conf" ];then
			echo link gfwlist.conf
			ln -sf /koolshare/ss/rules/gfwlist.conf /jffs/configs/dnsmasq.d/gfwlist.conf
		fi
		service restart_dnsmasq
#iptables要有nat表
		checkport=`iptables -t nat -nL OUTPUT|grep "match-set gfwlist dst redir ports 3333"`
		if [ -z "$checkport" ];then
			iptables -t nat -A OUTPUT -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-ports 3333 >/dev/null 2>&1
			#iptables -t nat -A OUTPUT -p udp -m set --match-set gfwlist dst -j REDIRECT --to-ports 3333 >/dev/null 2>&1
		fi
#ip6tables要有nat表
		checkport=`ip6tables -t nat -nL OUTPUT|grep "match-set gfwlist dst redir ports 3333"`
		if [ -z "$checkport" ];then
			ip6tables -t nat -A OUTPUT -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-ports 3333 >/dev/null 2>&1
			#ip6tables -t nat -A OUTPUT -p udp -m set --match-set gfwlist dst -j REDIRECT --to-ports 3333 >/dev/null 2>&1
		fi
	fi
}

del_output(){
	checkport=`iptables -t nat -nL OUTPUT|grep "match-set gfwlist dst redir ports 3333"`
	while [ "$checkport" != "" ]
	do
		iptables -t nat -D OUTPUT -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-ports 3333 >/dev/null 2>&1
		#iptables -t nat -D OUTPUT -p udp -m set --match-set gfwlist dst -j REDIRECT --to-ports 3333 >/dev/null 2>&1
		checkport=`iptables -t nat -nL OUTPUT|grep "match-set gfwlist dst redir ports 3333"`
	done
	checkport=`ip6tables -t nat -nL OUTPUT|grep "match-set gfwlist dst redir ports 3333"`
	while [ "$checkport" != "" ]
	do
		ip6tables -t nat -D OUTPUT -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-ports 3333 >/dev/null 2>&1
		#ip6tables -t nat -D OUTPUT -p udp -m set --match-set gfwlist dst -j REDIRECT --to-ports 3333 >/dev/null 2>&1
		checkport=`ip6tables -t nat -nL OUTPUT|grep "match-set gfwlist dst redir ports 3333"`
	done
}

case $ACTION in
start)
	ssrserver_start
	open_port
	write_nat_start
	#write_output
	;;
stop)
	ssrserver_stop
	close_port
	remove_nat_start
	#del_output
	;;
restart)
	close_port
	ssrserver_stop
	remove_nat_start
	#del_output
	ssrserver_start
	open_port
	write_nat_start
	#write_output
	;;
enable)
	auto_start enable
	;;
disable)
	auto_start disable
	;;
*)
	open_port
	#write_output
	;;
esac