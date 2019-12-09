#!/bin/sh
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'
eval `dbus export cfddns`

# 设置默认的信息
CONFIG_FILE="/tmp/cfddns_status.json"
[ "$cfddns_get_ipv4" = "" ] && cfddns_get_ipv4="curl -s --interface ppp0 whatismyip.akamai.com"
[ "$cfddns_get_ipv6" = "" ] && cfddns_get_ipv6="curl -s http://v4v6.ipv6-test.com/json/defaultproto.php | grep -oE '([a-f0-9]{1,4}(:[a-f0-9]{1,4}){7}|[a-f0-9]{1,4}(:[a-f0-9]{1,4}){0,7}::[a-f0-9]{0,4}(:[a-f0-9]{1,4}){0,7})'"
[ "$cfddns_ttl" = "" ] && cfddns_ttl=1
[ "$cfddns_proxied" = "" ] && cfddns_proxied="false"
[ "$cfddns_crontab_interval" = "" ] && cfddns_crontab_interval=0
[ "$cfddns_update_object" = "" ] && cfddns_update_object=both
get_type="A"

if [ $cfddns_crontab_interval -gt 0 ];then
	cfddns_crontab_interval_day=$(($cfddns_crontab_interval / 60 / 24))
echo "$cfddns_crontab_interval_day"
	if [ $cfddns_crontab_interval_day -eq 0 ];then
		_cfddns_crontab_interval_day="*"
	else
		_cfddns_crontab_interval_day="*/$cfddns_crontab_interval_day"
	fi
echo "$_cfddns_crontab_interval_day"


	cfddns_crontab_interval_hour=$(($cfddns_crontab_interval / 60 % 24))
	while [ $cfddns_crontab_interval_hour -gt 24 ]
	do
		cfddns_crontab_interval_hour=$(($cfddns_crontab_interval_hour % 24))
	done
echo "$cfddns_crontab_interval_hour"
	if [ "$_cfddns_crontab_interval_day" != "*" ];then
		_cfddns_crontab_interval_hour="0"
	elif [ $cfddns_crontab_interval_hour -eq 0 ];then
		_cfddns_crontab_interval_hour="*"
	else
		_cfddns_crontab_interval_hour="*/$cfddns_crontab_interval_hour"
	fi
echo "$_cfddns_crontab_interval_hour"


	cfddns_crontab_interval_min=$(($cfddns_crontab_interval % 60))
	while [ $cfddns_crontab_interval_min -gt 60 ]
	do
		cfddns_crontab_interval_min=$(($cfddns_crontab_interval_min % 60))
	done
echo "$cfddns_crontab_interval_min"
	if [ "$_cfddns_crontab_interval_day" != "*" ] || [ "$_cfddns_crontab_interval_hour" != "*" ];then
		_cfddns_crontab_interval_min="0"
	elif [ $cfddns_crontab_interval_min -eq 0 ];then
		_cfddns_crontab_interval_min="*"
	else
		_cfddns_crontab_interval_min="*/$cfddns_crontab_interval_min"
	fi
echo "$_cfddns_crontab_interval_min"
fi



# 获取CFDDNS的A记录结果
get_record_response() {
        curl -kLsX GET "https://api.cloudflare.com/client/v4/zones/$cfddns_zone_id/dns_records?type=$get_type&name=$cfddns_domain_name_frist.$cfddns_domain_name_last&order=type&direction=desc&match=all" \
                -H "X-Auth-Email: $cfddns_user_email" \
                -H "X-Auth-Key: $cfddns_api_key" \
                -H "Content-type: application/json"
}
# 更新CFDDNS的A记录
update_record() {
    curl -kLsX PUT "https://api.cloudflare.com/client/v4/zones/$cfddns_zone_id/dns_records/$cfddns_id" \
     -H "X-Auth-Email: $cfddns_user_email" \
     -H "X-Auth-Key: $cfddns_api_key" \
     -H "Content-Type: application/json" \
         --data '{"id":"'$cfddns_id'","type":"'$get_type'","name":"'$cfddns_domain_name_frist.$cfddns_domain_name_last'","content":"'$update_to_ip'","zone_id":"'$cfddns_zone_id'","zone_name":"'$cfddns_domain_name_last'","ttl":'$cfddns_ttl',"proxied":'$cfddns_proxied'}'
}

# 本地公网IPv4
get_local_ipv4(){
	local_ipv4=`$cfddns_get_ipv4`
	if [ $(echo $local_ipv4 | grep -c "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$") -gt 0 ]; then 
		echo_date 本地IPv4为 $local_ipv4
	else
		#cat > $CONFIG_FILE <<-EOF
		#	{"error":"获取本地IPv4失败","date":"$(date +%Y年%m月%d日\ %X)"}
		#EOF
		local_ipv4=""
		echo_date 获取本地IPv4失败!
	fi
	local_ipv4=$(eval $cfddns_get_ipv4 2>&1)

}
# cf IPv4
get_cf_ipv4(){
	get_type="A"
	# CFDDNS返回的JSON结果
	cfddns_result=`get_record_response`
	if [ $(echo $cfddns_result | grep -c "\"success\":true") -gt 0 ]; 
	then 
		# CFDDNS的A记录ID
		cfddns_id=`echo $cfddns_result | awk -F"","" '{print $1}' | sed 's/{.*://g' | sed 's/\"//g'`
		# CFDDNS的A记录IP
		cf_ipv4=`echo $cfddns_result | awk -F"","" '{print $4}' | grep -oE '([0-9]{1,3}\.?){4}'`
		echo_date cf IPv4为 $cf_ipv4
	else
		#cat > $CONFIG_FILE <<-EOF
		#	{"error":"获取cf IPv4错误","date":"$(date +%Y年%m月%d日\ %X)"}
		#EOF
		cf_ipv4=""
		echo_date 获取cf IPv4失败!结果如下：
		echo $cfddns_result
	fi
}

# 本地公网IPv6
get_local_ipv6(){
	local_ipv6=$(eval $cfddns_get_ipv6 2>&1)
	if [ "$local_ipv6" != "" ]; then 
		echo_date 本地IPv6为 $local_ipv6
	else
		#cat > $CONFIG_FILE <<-EOF
		#	{"error":"获取本地IPv6失败","date":"$(date +%Y年%m月%d日\ %X)"}
		#EOF
		local_ipv6=""
		echo_date 获取本地IPv6失败!
	fi
}

# cf IPv6
get_cf_ipv6(){
	get_type="AAAA"
	if [ "$local_ipv6" != "" ]; then 
		# CFDDNS返回的JSON结果
		cfddns_result=`get_record_response`
		if [ $(echo $cfddns_result | grep -c "\"success\":true") -gt 0 ]; 
		then 
			# CFDDNS的AAAA记录ID
			cfddns_id=`echo $cfddns_result | awk -F"","" '{print $1}' | sed 's/{.*://g' | sed 's/\"//g'`
			# CFDDNS的AAAA记录IP
			cf_ipv6=`echo $cfddns_result | awk -F"","" '{print $4}' | grep -oE '([a-f0-9]{1,4}(:[a-f0-9]{1,4}){7}|[a-f0-9]{1,4}(:[a-f0-9]{1,4}){0,7}::[a-f0-9]{0,4}(:[a-f0-9]{1,4}){0,7})'`
			echo_date cf IPv6为 $cf_ipv6
		else
			#cat > $CONFIG_FILE <<-EOF
			#	{"error":"获取cf IPv6失败","date":"$(date +%Y年%m月%d日\ %X)"}
			#EOF
			cf_ipv6=""
			echo_date 获取cf IPv6失败!结果如下：
			echo $cfddns_result
		fi
	fi
}


# 更新IP
update_ip(){
	if [ "$1" == "ipv4" ];then
		update_to_ip=$local_ipv4
	elif [ "$1" == "ipv6" ];then
		update_to_ip=$local_ipv6
	fi
	update_result=`update_record`
	if [ $(echo $update_result | grep -c "\"success\":true") -gt 0 ]; 
	then 
		echo_date 更新$1成功!!!
		if [ "$1" == "ipv4" ];then
			cf_ipv4=$local_ipv4
		elif [ "$1" == "ipv6" ];then
			cf_ipv6=$local_ipv6
		fi
	else
		echo_date 更新$1失败!请检查设置!!!
		echo $update_result
	fi
}
# 检查IP,不同就更新
check_update(){
	rm -rf $CONFIG_FILE
	if [ "$1" == "" ] || [ "$1" == "ipv4" ]; then
		if [ "$cfddns_update_object" == "ipv4" ] || [ "$cfddns_update_object" == "both" ]; then
#echo check ipv4
			#if [ "$cfddns_update_object" == "ipv4" ] || [ "$cfddns_update_object" == "both" ]; then
				if [ "$1" != "ipv4" ];then
#echo get ipv4
					get_local_ipv4
				fi
				if [ "$local_ipv4" != "" ];then 
					get_cf_ipv4
					if [ "$cf_ipv4" != "" ];then
						if [ "$local_ipv4" == "$cf_ipv4" ]; then
							echo_date IPv4相同。
						else
							echo_date IPv4不同,开始更新!
							update_ip IPv4
						fi
					else
						cf_ipv4=获取失败
						echo_date 获取cf IPv4失败，中止本次IPv4更新
					fi
				else
					local_ipv4=获取失败
					cf_ipv4=忽略
					echo_date 获取本地IPv4失败，中止本次IPv4更新
				fi
			#fi	
		else
			local_ipv4=未启用
			cf_ipv4=未启用
		fi
	else
		local_ipv4=未启用
		cf_ipv4=未启用
	fi
	
	if [ "$1" == "" ] || [ "$1" == "ipv6" ]; then
		if [ "$cfddns_update_object" == "ipv6" ] || [ "$cfddns_update_object" == "both" ]; then
#echo check ipv6
			#if [ "$cfddns_update_object" == "ipv6" ] || [ "$cfddns_update_object" == "both" ]; then
				if [ "$1" != "ipv6" ];then
#echo get ipv6
					get_local_ipv6
				fi
				if [ "$local_ipv6" != "" ];then 
					get_cf_ipv6
					if [ "$cf_ipv6" != "" ];then
						if [ "$local_ipv6" == "$cf_ipv6" ]; then
							echo_date IPv6相同。
						else
							echo_date IPv6不同,开始更新!
							update_ip ipv6
						fi
					else
						cf_ipv6=获取失败
						echo_date 获取cf IPv6失败，中止本次IPv6更新
					fi
				else
					local_ipv6=获取失败
					cf_ipv6=忽略
					echo_date 获取本地IPv6失败，中止本次IPv6更新
				fi
			#fi	
		else
			local_ipv6=未启用
			cf_ipv6=未启用
		fi
	else
		local_ipv6=未启用
		cf_ipv6=未启用
	fi
	cat > $CONFIG_FILE <<-EOF
	{"local_ipv4":"$local_ipv4","cf_ipv4":"$cf_ipv4","local_ipv6":"$local_ipv6","cf_ipv6":"$cf_ipv6","error":"none","date":"$(date +%Y年%m月%d日\ %X)"}
	EOF

}

get_status(){
	rm -rf $CONFIG_FILE
	if [ "$cfddns_update_object" == "both" ]; then
		get_local_ipv4
		if [ "$local_ipv4" == "" ];then
			local_ipv4=获取失败
		fi
		get_cf_ipv4
		if [ "$cf_ipv4" == "" ];then
			cf_ipv4=获取失败
		fi
		get_local_ipv6
		if [ "$local_ipv6" == "" ];then
			local_ipv6=获取失败
		fi
		get_cf_ipv6
		if [ "$cf_ipv6" == "" ];then
			cf_ipv6=获取失败
		fi
	elif [ "$cfddns_update_object" == "ipv4" ]; then
		get_local_ipv4
		if [ "$local_ipv4" == "" ];then
			local_ipv4=获取失败
		fi
		get_cf_ipv4
		if [ "$cf_ipv4" == "" ];then
			cf_ipv4=获取失败
		fi
		local_ipv6=未启用
		cf_ipv6=未启用
	elif [ "$cfddns_update_object" == "ipv6" ]; then
		get_local_ipv6
		if [ "$local_ipv6" == "" ];then
			local_ipv6=获取失败
		fi
		get_cf_ipv6
		if [ "$cf_ipv6" == "" ];then
			cf_ipv6=获取失败
		fi
		local_ipv4=未启用
		cf_ipv4=未启用
	fi
	cat > $CONFIG_FILE <<-EOF
	{"local_ipv4":"$local_ipv4","cf_ipv4":"$cf_ipv4","local_ipv6":"$local_ipv6","cf_ipv6":"$cf_ipv6","error":"none","date":"$(date +%Y年%m月%d日\ %X)"}
	EOF
}

# 执行更新
do_start(){
	get_ip_try_time=12
	if [ "$1" == "auto-start" ];then
		try_interval=300
	else
		try_interval=5
	fi
	if [ "$cfddns_update_object" == "ipv4" ] || [ "$cfddns_update_object" == "both" ]; then
		get_ipv4_counts=1
		get_local_ipv4
		until [ "$local_ipv4" != "" -o $get_ipv4_counts -gt $get_ip_try_time ]
		do
			echo_date $try_interval秒后重试
			sleep $try_interval
			#echo_date 获取本地IPv4失败
			echo_date 尝试获取IPv4第 $get_ipv4_counts 次
			let "get_ipv4_counts++"
			get_local_ipv4
		done
		
		if [ "$local_ipv4" != "" ];then
			check_update ipv4
		else
			echo_date 多次获取本地IPv4失败，不执行IPv4的DDNS更新。
		fi
	fi
	
	if [ "$cfddns_update_object" == "ipv6" ] || [ "$cfddns_update_object" == "both" ]; then
		get_ipv6_counts=1
		get_local_ipv6
		until [ "$local_ipv6" != "" -o $get_ipv6_counts -gt $get_ip_try_time ]
		do
			echo_date $try_interval秒后重试
			sleep $try_interval
			#echo_date 获取本地IPv6失败
			echo_date 尝试获取IPv6第 $get_ipv6_counts 次
			let "get_ipv6_counts++"
			get_local_ipv6
		done

		if [ "$local_ipv6" != "" ];then
			check_update ipv6
		else
			echo_date 多次获取本地IPv6失败,不执行IPv6的DDNS更新。
		fi
	fi

	wan_auto_start
}
# wan口开机启动
wan_auto_start(){
	# Add service to auto start
	if [ ! -f /jffs/scripts/wan-start ]; then
		cat > /jffs/scripts/wan-start <<-EOF
			#!/bin/sh
			dbus fire onwanstart
			
			EOF
	fi
	
	startss=$(cat /jffs/scripts/wan-start | grep "/koolshare/scripts/cfddns_run.sh")
	if [ -z "$startss" ];then
		echo_date 添加wan-start触发事件...用于程序的开机启动...
		sed -i '2a sh /koolshare/scripts/cfddns_run.sh auto-start &' /jffs/scripts/wan-start
	fi
	
	
	if [ $cfddns_crontab_interval -gt 0 ];then
		crontab_task=`cru l|grep cf_ddns_synctask`
#echo $crontab_task
#echo "$_cfddns_crontab_interval_min $_cfddns_crontab_interval_hour $_cfddns_crontab_interval_day * * /koolshare/scripts/cfddns_run.sh update"
		if [ -z "$crontab_task" ];then
			echo_date 添加Crontab定时任务，每$cfddns_crontab_interval_min分钟$cfddns_crontab_interval_hour小时$cfddns_crontab_interval_day天检测一次。
			cru a cf_ddns_synctask "$_cfddns_crontab_interval_min $_cfddns_crontab_interval_hour $_cfddns_crontab_interval_day * * /koolshare/scripts/cfddns_run.sh update false"
		elif [ "$1" == "true" ];then #if [ "$crontab_task" != "$_cfddns_crontab_interval_min $_cfddns_crontab_interval_hour $_cfddns_crontab_interval_day * * /koolshare/scripts/cfddns_run.sh update #cf_ddns_synctask#" ];then
			echo_date 更新Crontab定时任务，每$cfddns_crontab_interval_min分钟$cfddns_crontab_interval_hour小时$cfddns_crontab_interval_day天检测一次。
			cru d cf_ddns_synctask
			cru a cf_ddns_synctask "$_cfddns_crontab_interval_min $_cfddns_crontab_interval_hour $_cfddns_crontab_interval_day * * /koolshare/scripts/cfddns_run.sh update false"
		fi
	fi
	chmod +x /jffs/scripts/wan-start
}
do_stop(){
	echo_date 删除开机启动
	sed -i '/cfddns_run.sh/d' /jffs/scripts/wan-start >/dev/null 2>&1
	echo_date 删除Crontab定时任务
	cru d cf_ddns_synctask
}

case $1 in
auto-start)
	if [ ! -f "/tmp/cfddns.nat_lock" -a "$cfddns_enable" -eq "1" ];then
		touch /tmp/cfddns.nat_lock
		echo_date "---开机启动---" >> /tmp/cfddns_log.log
		sleep 20
		until [ $(date +%Y) -gt 2017 ]
		do
			sleep 5
		done
		do_start auto-start >> /tmp/cfddns_log.log
		rm -rf /tmp/cfddns.nat_lock
		echo_date "---开机启动完成---" >> /tmp/cfddns_log.log
	else
		logger "[软件中心]: CFDDNS插件未开启，不启动！"
	fi
	;;
update)
	check_update >> /tmp/cfddns_log.log
	if [ "$2" == "" ];then
		wan_auto_start true >> /tmp/cfddns_log.log
	else
		wan_auto_start false >> /tmp/cfddns_log.log
	fi
	;;
status)
	get_status >> /tmp/cfddns_log.log
	;;
start)
	do_start >> /tmp/cfddns_log.log
	;;
stop)
	do_stop >> /tmp/cfddns_log.log
	;;
esac