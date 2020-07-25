#!/bin/sh
tmp_dir='/tmp/Cloudflare'
if [ ! -d $tmp_dir ];then
	mkdir $tmp_dir
fi
LOCK_FILE="$tmp_dir"'/cfddns_run.lock'
if [ -f $LOCK_FILE ];then
	i=0
	for pid in `ps | grep -v grep | grep "$0" | awk '{print $1}'`
	do
		if [ -z "$pid" ];then
			break
		elif [ $pid -eq $$ ];then
			continue
		fi
		i=$(( $i + 1 ))
	done
	if [ $i -gt 2 ];then
		exit 0
	fi
else
	touch $LOCK_FILE
fi

alias echo_date='echo $(date +%Y年%m月%d日\ %X):'
eval `dbus export cfddns`
dir=$(dirname $0)
cd $dir

jq_path="`which jq`"
LOG_FILE="$tmp_dir"'/cfddns_log.log'
STATUS_FILE="$tmp_dir"'/cfddns_status.json'
STATUS_FILE_SHOW="$tmp_dir"'/cfddns_status_show.json'
CACHE_FILE="$tmp_dir"'/cfddns_cache'
readonly LOG_FILE
readonly STATUS_FILE
readonly STATUS_FILE_SHOW
readonly CACHE_FILE

if [ x"$cfddns_enable" = x"true" ];then
	rm -rf $LOG_FILE
fi

echo_date '脚本运行，如需变更设置，请等待脚本运行完毕，否则变更可能不会生效！' >> $LOG_FILE
if [ -z "$jq_path" ];then
	echo_date '缺少依赖包"jq"'
	rm -rf $LOCK_FILE
	exit 0
fi
startup=false
if [ "$1" == 'startup' ];then
	startup=true
	echo_date '---开机启动---' >> $LOG_FILE
	until [ $(date +%Y) -gt 2019 ]
	do
		sleep 5
	done
fi



crontab_task=`cru l | grep cf_ddns_synctask`
#echo debug crontab_task = "$crontab_task" >> $LOG_FILE
startup_cmd=$(cat /jffs/scripts/wan-start | grep "/koolshare/scripts/cfddns_run.sh")

if [ x"$cfddns_enable" = x"true" ];then
	config='{"user":{"email":"'"$cfddns_user_email"'","global_api_key":"'"$cfddns_global_api_key"'"},"auto_create_zone":true,"auto_create_zone_jump_start":false,"auto_create_zone_type":"full","auto_create_record":true,"auto_delete_redundant_records":false,"domains":[{"root_domain_name":"'"$cfddns_root_domain_name"'","auto_create_zone":'"$cfddns_auto_create_zone"',"auto_create_zone_jump_start":'"$cfddns_auto_create_zone_jump_start"',"auto_create_zone_type":"'"$cfddns_auto_create_zone_type"'","hosts":[{"subdomain_name_prefix":"'"$cfddns_subdomain_name_prefix"'","records":['
	if [ x"$cfddns_update_object" = x"ipv4" ];then
		config="$config"'{"type":"A","content":"'"$cfddns_ipv4_content"'","ttl":'"$cfddns_ipv4_ttl"',"proxied":'"$cfddns_ipv4_proxied"',"auto_create_record":'"$cfddns_ipv4_auto_create_record"',"auto_delete_redundant_records":'"$cfddns_ipv4_auto_delete_redundant_records"'}'
	elif [ x"$cfddns_update_object" = x"ipv6" ];then
		config="$config"'{"type":"AAAA","content":"'"$cfddns_ipv6_content"'","ttl":'"$cfddns_ipv6_ttl"',"proxied":'"$cfddns_ipv6_proxied"',"auto_create_record":'"$cfddns_ipv6_auto_create_record"',"auto_delete_redundant_records":'"$cfddns_ipv6_auto_delete_redundant_records"'}'
	elif [ x"$cfddns_update_object" = x"both" ];then
		config="$config"'{"type":"A","content":"'"$cfddns_ipv4_content"'","ttl":'"$cfddns_ipv4_ttl"',"proxied":'"$cfddns_ipv4_proxied"',"auto_create_record":'"$cfddns_ipv4_auto_create_record"',"auto_delete_redundant_records":'"$cfddns_ipv4_auto_delete_redundant_records"'},{"type":"AAAA","content":"'"$cfddns_ipv6_content"'","ttl":'"$cfddns_ipv6_ttl"',"proxied":'"$cfddns_ipv6_proxied"',"auto_create_record":'"$cfddns_ipv6_auto_create_record"',"auto_delete_redundant_records":'"$cfddns_ipv6_auto_delete_redundant_records"'}'
	fi
	config="$config"']}]}],"get_ipv4_cmd":"'${cfddns_get_ipv4_cmd//\\/}'","get_ipv4_url":"'"$cfddns_get_ipv4_url"'","get_ipv6_cmd":"'${cfddns_get_ipv6_cmd//\\/}'","get_ipv6_url":"'"$cfddns_get_ipv6_url"'","check_interval":0}'
#echo 'debug config = '"$config" >> $LOG_FILE
	config=`echo "$config" | $jq_path -c .`
	if [ -n "$config" ];then
		echo "$config" | $jq_path . > /koolshare/configs/cfddns.json
		echo_date '开启CFDDNS!!!' >> $LOG_FILE
		echo "running" > $STATUS_FILE_SHOW
		if [ x"$startup" = x"true" ];then
			./cfddns.sh startup --jq="$jq_path" --config=/koolshare/configs/cfddns.json  >> $LOG_FILE
		else
			./cfddns.sh start --jq="$jq_path" --config=/koolshare/configs/cfddns.json >> $LOG_FILE
		fi
		
		if [ $cfddns_crontab_interval -gt 0 ];then
			_cfddns_crontab_interval_min=""
			_cfddns_crontab_interval_hour=""
			_cfddns_crontab_interval_day=""
			
			cfddns_crontab_interval_day=$(($cfddns_crontab_interval / 60 / 24))
#echo debug cfddns_crontab_interval_day = $cfddns_crontab_interval_day >> $LOG_FILE
			if [ $cfddns_crontab_interval_day -eq 0 ];then
				_cfddns_crontab_interval_day='*'
			else
				_cfddns_crontab_interval_day='*/'$cfddns_crontab_interval_day >> $LOG_FILE
			fi
#echo debug _cfddns_crontab_interval_day = "$_cfddns_crontab_interval_day" >> $LOG_FILE
			
			
			cfddns_crontab_interval_hour=$(($cfddns_crontab_interval / 60 % 24))
			while [ $cfddns_crontab_interval_hour -gt 24 ]
			do
				cfddns_crontab_interval_hour=$(($cfddns_crontab_interval_hour % 24))
			done
#echo debug cfddns_crontab_interval_hour = $cfddns_crontab_interval_hour >> $LOG_FILE
			if [ "$_cfddns_crontab_interval_day" != '*' ];then
				_cfddns_crontab_interval_hour="0"
			elif [ $cfddns_crontab_interval_hour -eq 0 ];then
				_cfddns_crontab_interval_hour='*'
			else
				_cfddns_crontab_interval_hour='*/'$cfddns_crontab_interval_hour
			fi
#echo debug _cfddns_crontab_interval_hour = "$_cfddns_crontab_interval_hour" >> $LOG_FILE
			
			
			cfddns_crontab_interval_min=$(($cfddns_crontab_interval % 60))
			while [ $cfddns_crontab_interval_min -gt 60 ]
			do
				cfddns_crontab_interval_min=$(($cfddns_crontab_interval_min % 60))
			done
#echo debug cfddns_crontab_interval_min = $cfddns_crontab_interval_min >> $LOG_FILE
			if [ "$_cfddns_crontab_interval_day" != '*' ] || [ "$_cfddns_crontab_interval_hour" != '*' ];then
				_cfddns_crontab_interval_min=0
			elif [ $cfddns_crontab_interval_min -eq 0 ];then
				_cfddns_crontab_interval_min='*'
			else
				_cfddns_crontab_interval_min='*/'$cfddns_crontab_interval_min
			fi
#echo debug _cfddns_crontab_interval_min = "$_cfddns_crontab_interval_min" >> $LOG_FILE
			
			crontab_cmd="$_cfddns_crontab_interval_min $_cfddns_crontab_interval_hour $_cfddns_crontab_interval_day"' * * /koolshare/scripts/cfddns.sh start --jq='"$jq_path"' --config=/koolshare/configs/cfddns.json && /koolshare/scripts/cfddns_status.sh skip'
#echo debug crontab_cmd = "$crontab_cmd" >> $LOG_FILE
			if [ -z "$crontab_task" ];then
				echo_date '添加Crontab定时任务，每'"$cfddns_crontab_interval_min"'分钟'"$cfddns_crontab_interval_hour"'小时'"$cfddns_crontab_interval_day"'天检测一次。' >> $LOG_FILE
				cru a cf_ddns_synctask "$crontab_cmd"
			else
				crontab_task1="`echo "$crontab_task" | awk -F' #' '{print $1}'`"
#echo debug crontab_task1 = "$crontab_task1" >> $LOG_FILE
				if [ x"$crontab_cmd" != x"$crontab_task1" ];then
					echo_date '更新Crontab定时任务，每'"$cfddns_crontab_interval_min"'分钟'"$cfddns_crontab_interval_hour"'小时'"$cfddns_crontab_interval_day"'天检测一次。' >> $LOG_FILE
					cru d cf_ddns_synctask
					cru a cf_ddns_synctask "$crontab_cmd"
				else
					echo_date '已添加Crontab定时任务，每'"$cfddns_crontab_interval_min"'分钟'"$cfddns_crontab_interval_hour"'小时'"$cfddns_crontab_interval_day"'天检测一次。' >> $LOG_FILE
				fi
			fi
		else
			if [ -n "$crontab_task" ];then
				echo_date '删除Crontab定时任务' >> $LOG_FILE
				cru d cf_ddns_synctask
			fi
		fi
			
		# Add service to auto start
		if [ ! -f /jffs/scripts/wan-start ]; then
			cat > /jffs/scripts/wan-start <<-EOF
				#!/bin/sh
				dbus fire onwanstart
				
				EOF
			chmod +x /jffs/scripts/wan-start
		fi
		
		if [ -z "$startup_cmd" ];then
			echo_date '添加wan-start触发事件...用于程序的开机启动...' >> $LOG_FILE
			sed -i '2a sh /koolshare/scripts/cfddns_run.sh startup --jq='"$jq_path"' --config=/koolshare/configs/cfddns.json && /koolshare/scripts/cfddns_status.sh skip &' /jffs/scripts/wan-start
		else
			echo_date '已添加wan-start触发事件...用于程序的开机启动...' >> $LOG_FILE
		fi
		
		echo_date '运行完毕!!!' >> $LOG_FILE
		if [ x"$startup" = x"true" ];then
			echo_date '---开机启动完成---' >> $LOG_FILE
		fi
		./cfddns_status.sh skip
	else
		echo_date 'error to build configuration, ask for help' >> $LOG_FILE
	fi
else
	if [ x"$startup" = x"true" ];then
		logger "[软件中心]: CFDDNS插件未启用，不启动！"
	else
		echo_date '关闭CFDDNS' >> $LOG_FILE
		./cfddns.sh stop >> $LOG_FILE
		
		if [ -n "$startup_cmd" ];then
			echo_date '删除开机启动' >> $LOG_FILE
			sed -i '/cfddns_run.sh/d' /jffs/scripts/wan-start >/dev/null 2>&1
		fi
		if [ -n "$crontab_task" ];then
			echo_date '删除Crontab定时任务' >> $LOG_FILE
			cru d cf_ddns_synctask
		fi
		if [ -f $STATUS_FILE_SHOW ];then
			rm -rf $STATUS_FILE_SHOW
		fi
		if [ -f $STATUS_FILE ];then
			rm -rf $STATUS_FILE
		fi
		if [ -f $CACHE_FILE ];then
			rm -rf $CACHE_FILE
		fi
		
		echo_date '运行完毕!!!' >> $LOG_FILE
	fi
fi
rm -rf $LOCK_FILE
