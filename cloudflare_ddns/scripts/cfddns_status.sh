#!/bin/sh
tmp_dir='/tmp/Cloudflare'
LOCK_FILE="$tmp_dir"'/cfddns_status.lock'
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


jq_path='/koolshare/bin/jq'
LOG_FILE="$tmp_dir"'/cfddns_log.log'
STATUS_FILE="$tmp_dir"'/cfddns_status.json'
STATUS_FILE_SHOW="$tmp_dir"'/cfddns_status_show.json'
CFDDNS_CACHE_FILE="$tmp_dir"'/cfddns_cache'
readonly LOG_FILE
readonly STATUS_FILE
readonly STATUS_FILE_SHOW
readonly CFDDNS_CACHE_FILE

errors=""

local_ipv4=""
cf_ipv4=""
local_ipv6=""
cf_ipv6=""

cf_ipv4_key=$cfddns_root_domain_name.$cfddns_subdomain_name_prefix.A.content
cf_ipv4_key=${cf_ipv4_key//./_}
cf_ipv6_key=$cfddns_root_domain_name.$cfddns_subdomain_name_prefix.AAAA.content
cf_ipv6_key=${cf_ipv6_key//./_}

cache=""
if [ "$1" == "skip" ];then
#echo 'debug skip' >> $LOG_FILE
	cache=`$jq_path -c . $CFDDNS_CACHE_FILE`
else
	echo 'running' > $STATUS_FILE_SHOW
	./cfddns.sh status --jq=/koolshare/bin/jq --config=/koolshare/configs/cfddns.json
	cache=`$jq_path -c . $STATUS_FILE`
fi
#echo 'debug cache = '"$cache" >> $LOG_FILE

if [ -z "$cache" ];then
	cat > $STATUS_FILE_SHOW <<-EOF
	{"local_ipv4":"null","cf_ipv4":"null","local_ipv6":"null","cf_ipv6":"null","error":"CFDDNS没有正常执行或生成了无效结果，查看日志获取详细信息","date":"$(date +%Y年%m月%d日\ %X)"}
	EOF
	rm -rf $LOCK_FILE
	exit 0
fi
errors=`echo "$cache" | $jq_path -r .errors`
if [ "$errors" == "null" ];then
	errors="none"
fi
#echo 'debug errors = '"$errors" >> $LOG_FILE
if [ "$errors" != "none" ];then
#echo 'debug errors' >> $LOG_FILE
	cat > $STATUS_FILE_SHOW <<-EOF
	{"error":"$errors","date":"$(date +%Y年%m月%d日\ %X)"}
	EOF
	rm -rf $LOCK_FILE
	exit 0
fi

if [ "$cfddns_update_object" == "ipv4" ];then
	local_ipv4=`echo "$cache" | $jq_path -r .local_ipv4`
	cf_ipv4=`echo "$cache" | $jq_path -r .$cf_ipv4_key`
	local_ipv6="未启用"
	cf_ipv6="未启用"
elif [ "$cfddns_update_object" == "ipv6" ];then
	local_ipv4="未启用"
	cf_ipv4="未启用"
	local_ipv6=`echo "$cache" | $jq_path -r .local_ipv6`
	cf_ipv6=`echo "$cache" | $jq_path -r .$cf_ipv6_key`
else
	local_ipv4=`echo "$cache" | $jq_path -r .local_ipv4`
	cf_ipv4=`echo "$cache" | $jq_path -r .$cf_ipv4_key`
	local_ipv6=`echo "$cache" | $jq_path -r .local_ipv6`
	cf_ipv6=`echo "$cache" | $jq_path -r .$cf_ipv6_key`
fi
if [ -z "$local_ipv4" ];then
	local_ipv4="获取失败"
fi
if [ -z "$cf_ipv4" ];then
	cf_ipv4="获取失败"
fi
if [ -z "$local_ipv6" ];then
	local_ipv6="获取失败"
fi
if [ -z "$cf_ipv6" ];then
	cf_ipv6="获取失败"
fi

cat > $STATUS_FILE_SHOW <<-EOF
{"local_ipv4":"$local_ipv4","cf_ipv4":"$cf_ipv4","local_ipv6":"$local_ipv6","cf_ipv6":"$cf_ipv6","error":"$errors","date":"$(date +%Y年%m月%d日\ %X)"}
EOF
rm -rf $LOCK_FILE
exit 0
