#!/bin/sh
alias echo_date='echo $(date +%Y年%m月%d日\ %X): '
dir=$(dirname $0)

jq_path=""
CONFIG_FILE=""
for opt in $*
do
	tmp=${opt:0:2}
#echo 'debug tmp = '"$tmp"
	if [ "$tmp" != "--" ];then
		continue
	fi
	key=`echo "$opt" | awk -F= '{print $1}'`
#echo 'debug key = '"$key"
	case $key in
	--config)
		val=`echo "$opt" | awk -F= '{print $2}'`
#echo 'debug val = '"$val"
			if [ -n "`echo "$val" | grep "/cfddns.json"`" ];then
				CONFIG_FILE="$val"
			else
				echo '"config.json" path is invalid'
			fi
		;;
	--jq)
		val=`echo "$opt" | awk -F= '{print $2}'`
#echo 'debug val = '"$val"
			if [ -n "`echo "$val" | grep "/jq"`" ];then
				jq_path="$val"
			else
				echo '"jq" path is invalid'
			fi
		;;
	*)
		echo 'Unknown option "'"$key"'"'
		;;
	esac
done
if [ -z "$CONFIG_FILE" ];then
	CONFIG_FILE=$dir'/cfddns.json'
fi
readonly CONFIG_FILE

tmp_dir='/tmp/Cloudflare'
if [ ! -d $tmp_dir ];then
	mkdir $tmp_dir
fi
LOG_FILE=$tmp_dir'/cfddns_log.log'
readonly LOG_FILE
if [ -z "$jq_path" ];then
#echo 'debug jq_path set by "which jq"'
	jq_path=`which jq`
fi
readonly jq_path
#_pid=$$
process_list_cmd=""
if [ "`ps | awk 'NR==1{print $2}' | tr [a-z] [A-Z]`" == "TTY" ];then
	process_list_cmd='ps -ef'
else
	process_list_cmd='ps'
fi
pid_col=0
i=0
for str in `$process_list_cmd | awk 'NR==1'`
do
	i=$(( $i + 1 ))
	if [ `echo "$str" | tr [a-z] [A-Z]` == "PID" ];then
		pid_col=$i
echo_date 'pid in column '"$pid_col" >> $LOG_FILE
		break;
	fi
done
unset i
if [ $pid_col -eq 0 ];then
	echo_date 'Can not get the column number where the "pid" is located, please ask for help'
	exit 1
fi


base_url='https://api.cloudflare.com/client/v4/'
ipv4_regex='([0-9]{1,3}.){3}[0-9]{1,3}'
ipv6_regex='[0-9a-fA-F]{1,4}:([0-9a-fA-F]{0,4}:){1,6}[0-9a-fA-F]{1,4}'
email_regex='^[a-zA-Z0-9_.-]{1,32}@[a-zA-Z0-9-]{1,32}(.[a-zA-Z0-9-]{1,32})*.[a-zA-Z0-9]{1,32}$'
number_regex='^[0-9]+$'
readonly base_url
readonly ipv4_regex
readonly ipv6_regex
readonly email_regex
readonly number_regex


# 设置信息
STATUS_FILE=$tmp_dir'/cfddns_status.json'
readonly STATUS_FILE
just_get_status=false
cfddns_status_cache=""

cfddns_config=""

user_email=""
global_api_key=""

zone_id=""
zone_name=""
auto_create_zone=true
zone_jump_start=false
zone_type=full

dns_record_id=""
dns_record_type=""
dns_record_name_prefix=""
dns_record_full_name=""
dns_record_content=""
dns_record_ttl=0
dns_record_proxied=false

auto_create_record=false
auto_delete_redundant_records=false

load_zone=-1
load_dns_record=-1

g_auto_create_zone=true
g_zone_jump_start=false
g_zone_type=full
g_auto_create_record=true
g_auto_delete_redundant_records=false

get_ipv4_cmd=""
get_ipv4_url=""
get_ipv6_cmd=""
get_ipv6_url=""

verify_account=-1
verify_zone=-1
cf_zone_id=""
cf_zone_name=""
cf_record_id=""
cf_record_prefix=""
cf_record_type=""
cf_record_content=""
cf_record_ttl=0
cf_record_proxied=false

check_interval=0

local_ipv4=""
local_ipv6=""
try_get_ipv4=0
try_get_ipv6=0

CACHE_FILE=$tmp_dir'/cfddns_cache'
readonly CACHE_FILE
cfddns_cache=""
cfddns_last_cache=""

result_json=""
result_errors=""
result_messages=""

errors=""

get_ip_try_times=3
get_ip_try_interval=10


show_memory(){
	cat >> $LOG_FILE <<-EOF
--------------------------------------------
dir = $dir

tmp_dir = $tmp_dir
LOG_FILE = $LOG_FILE
jq_path = $jq_path
process_list_cmd = $process_list_cmd
pid_col = $pid_col

CONFIG_FILE = $CONFIG_FILE
cfddns_config = $cfddns_config

STATUS_FILE = $STATUS_FILE
user_email = $user_email
global_api_key = $global_api_key

zone_id = $zone_id
zone_name = $zone_name
auto_create_zone = $auto_create_zone
zone_jump_start = $zone_jump_start
zone_type = $zone_type

dns_record_id = $dns_record_id
dns_record_type = $dns_record_type
dns_record_name_prefix = $dns_record_name_prefix
dns_record_full_name = $dns_record_full_name
dns_record_content = $dns_record_content
dns_record_ttl = $dns_record_ttl
dns_record_proxied = $dns_record_proxied

auto_create_record = $auto_create_record
auto_delete_redundant_records = $auto_delete_redundant_records

load_zone = $load_zone
load_dns_record = $load_dns_record

g_auto_create_zone = $g_auto_create_zone
g_zone_jump_start = $g_zone_jump_start
g_zone_type = $g_zone_type
g_auto_create_record = $g_auto_create_record
g_auto_delete_redundant_records = $g_auto_delete_redundant_records

get_ipv4_cmd = $get_ipv4_cmd
get_ipv4_url = $get_ipv4_url
get_ipv6_cmd = $get_ipv6_cmd
get_ipv6_url = $get_ipv6_url

verify_account = $verify_account
verify_zone = $verify_zone
cf_zone_id = $cf_zone_id
cf_zone_name = $cf_zone_name
cf_record_id = $cf_record_id
cf_record_prefix = $cf_record_prefix
cf_record_type = $cf_record_type
cf_record_content = $cf_record_content
cf_record_ttl = $cf_record_ttl
cf_record_proxied = $cf_record_proxied

check_interval = $check_interval

local_ipv4 = $local_ipv4
local_ipv6 = $local_ipv6
try_get_ipv4 = $try_get_ipv4
try_get_ipv6 = $try_get_ipv6

CACHE_FILE = $CACHE_FILE
cfddns_cache = $cfddns_cache
cfddns_last_cache = $cfddns_last_cache
--------------------------------------------
EOF
}

load_config(){
#echo 'debug enter load_config'
#echo 'debug enter cfddns_config'
	cfddns_config=`$jq_path -c . $CONFIG_FILE`
#echo 'debug enter cfddns_config = '"$cfddns_config"
	if [ -z "$cfddns_config" ];then
		echo_date 'The content of the configuration file is not in json format, please check "'"$CONFIG_FILE"'" and try again'
		return 1
	fi
	
#echo 'debug load_config chk_user'
	chk_user=`echo "$cfddns_config" | $jq_path -c .user`
	if [ -z "$chk_user" -o "$chk_user" == "null" ];then
		echo_date 'Configuration error, must contain "user" group and "user" group contains an "email" field with a value and a "global_api_key" field with a value'
		return 1
	fi
#echo 'debug load_config chk_user = '"$chk_user"
	
#echo 'debug load_config user_email'
	user_email=`echo "$chk_user" | $jq_path -r .email | grep -oE "$email_regex"`
	if [ -z "$user_email" -o "$user_email" == "null" ];then
		echo_date '"user_email" is REQUIRED, but is empty or non-email format!'
		return 1
	fi
#echo 'debug load_config user_email = '"$user_email"
	
#echo 'debug load_config global_api_key'
	global_api_key=`echo "$chk_user" | $jq_path -r .global_api_key`
	if [ -z "$global_api_key" -o "$global_api_key" == "null" ];then
		echo_date '"global_api_key" is REQUIRED!'
		return 1
	fi
#echo 'debug load_config global_api_key = '"$global_api_key"
	
#echo 'debug load_config chk_domains'
	chk_domains=`echo "$cfddns_config" | $jq_path -c .domains`
	if [ -z "$chk_domains" -o "$chk_domains" == "null" ];then
		echo_date 'Configuration error, must contain a "domains" array field with at least a group which contains a "root_domain_name" field with value and a "hosts" array field with at least a group which must contain a "subdomain_name_prefix" field with value and a "records" array field with at least a group which must contain a "type" field with value, a "ttl" field with value and a "proxied" field with value'
#echo 'debug chk_domains = '"$chk_domains"
		return 1
	fi
#echo 'debug load_config chk_domains = '"$chk_domains"
	
	i=-1
	while true
	do
		i=$(( $i + 1 ))
#echo 'debug load_config i = '"$i"
#echo 'debug load_config chk_domain'
		chk_domain=`echo "$cfddns_config" | $jq_path -c .domains[$i]`
		if [ $i -eq 0 -a "$chk_domain" == "null" ];then
			echo_date 'Configuration error, must contain at least a group which contains a "root_domain_name" field with value and a "hosts" array field with at least a group which must contain a "subdomain_name_prefix" field with value and a "records" array field with at least a group which must contain a "type" field with value, a "ttl" field with value and a "proxied" field with value'
#echo 'debug chk_domain = '"$chk_domain"
			return 1
		fi
#echo 'debug load_config chk_domain = '"$chk_domain"
		if [ -z "$chk_domain" -o "$chk_domain" == "null" ];then
			break
		fi
#echo 'debug load_config chk_root_domain_name'
		chk_root_domain_name=`echo "$chk_domain" | $jq_path -r .root_domain_name`
		if [ -z "$chk_root_domain_name" -o "$chk_root_domain_name" == "null" ];then
			echo_date 'Configuration error, must contain "root_domain_name" field with value'
#echo 'debug chk_root_domain_name = '"$chk_root_domain_name"
			return 1
		fi
#echo 'debug load_config chk_root_domain_name = '"$chk_root_domain_name"

#echo 'debug load_config chk_hosts'
		chk_hosts=`echo "$chk_domain" | $jq_path -c .hosts`
		if [ -z "$chk_hosts" -o "$chk_hosts" == "null" ];then
			echo_date 'Configuration error, must contain a "hosts" array field with at least a group which must contain a "subdomain_name_prefix" field with value and a "records" array field with at least a group which must contain a "type" field with value, a "ttl" field with value and a "proxied" field with value'
#echo 'debug chk_hosts = '"$chk_hosts"
			return 1
		fi
#echo 'debug load_config chk_hosts = '"$chk_hosts"
		j=-1
		while true
		do
			j=$(( $j + 1 ))
#echo 'debug load_config j = '"$j"
#echo 'debug load_config chk_host'
			chk_host=`echo "$chk_domain" | $jq_path -c .hosts[$j]`
			if [ $j -eq 0 -a "$chk_host" == "null" ];then
				echo_date 'Configuration error, must contain at least a group which must contain a "subdomain_name_prefix" field with value and a "records" array field with at least a group which must contain a "type" field with value, a "ttl" field with value and a "proxied" field with value'
#echo 'debug chk_host = '"$chk_host"
				return 1
			fi
#echo 'debug load_config chk_host = '"$chk_host"
			if [ -z "$chk_host" -o "$chk_host" == "null" ];then
				break
			fi
#echo 'debug load_config chk_subdomain_name_prefix'
			chk_subdomain_name_prefix=`echo "$chk_host" | $jq_path -r .subdomain_name_prefix`
			if [ "$chk_subdomain_name_prefix" == "null" ];then
				echo_date 'Configuration error, must contain a "subdomain_name_prefix" field'
#echo 'debug chk_subdomain_name_prefix = '"$chk_subdomain_name_prefix"
				return 1
			fi
#echo 'debug load_config chk_subdomain_name_prefix = '"$chk_subdomain_name_prefix"
#echo 'debug load_config chk_records'
			chk_records=`echo "$chk_host" | $jq_path -c .records`
			if [ -z "$chk_records" -o "$chk_records" == "null" ];then
				echo_date 'Configuration error, must contain a "records" array field with at least a group which must contain a "type" field with value, a "ttl" field with value and a "proxied" field with value'
#echo 'debug chk_records = '"$chk_records"
				return 1
			fi
#echo 'debug load_config chk_records = '"$chk_records"
			k=-1
			while true
			do
				k=$(( $k + 1 ))
#echo 'debug load_config k = '"$k"
#echo 'debug load_config chk_record'
				chk_record=`echo "$chk_host" | $jq_path -c .records[$k]`
				if [ $k -eq 0 -a "$chk_record" == "null" ];then
					echo_date 'Configuration error, must contain a "records" array field with at least a group which must contain a "type" field with value, a "ttl" field with value and a "proxied" field with value'
#echo 'debug chk_record = '"$chk_record"
					return 1
				fi
#echo 'debug load_config chk_record = '"$chk_record"
				if [ -z "$chk_record" -o "$chk_record" == "null" ];then
					break
				fi
#echo 'debug load_config chk_type'
				chk_field=`echo "$chk_record" | $jq_path -r .type`
				if [ -z "$chk_field" -o "$chk_field" == "null" ];then
					echo_date 'Configuration error, must contain a "type" field with value'
#echo 'debug chk_field = '"$chk_field"
					return 1
				fi
#echo 'debug load_config chk_type = '"$chk_field"
#echo 'debug load_config chk_ttl'
				chk_field=`echo "$chk_record" | $jq_path -r .ttl`
				if [ -z "$chk_field" -o "$chk_field" == "null" ];then
					echo_date 'Configuration error, must contain a "ttl" field with value'
#echo 'debug chk_field = '"$chk_field"
					return 1
				fi
#echo 'debug load_config chk_ttl = '"$chk_field"
#echo 'debug load_config chk_proxied'
				chk_field=`echo "$chk_record" | $jq_path -r .proxied`
				if [ -z "$chk_field" -o "$chk_field" == "null" ];then
					echo_date 'Configuration error, must contain a "proxied" field with value'
#echo 'debug chk_field = '"$chk_field"
					return 1
				fi
#echo 'debug load_config chk_proxied = '"$chk_field"
				
			done
		done
	done
	
	
	get_ipv4_cmd=`echo "$cfddns_config" | $jq_path -r .get_ipv4_cmd`
	get_ipv4_url=`echo "$cfddns_config" | $jq_path -r .get_ipv4_url`
	if [ -n "`echo "$cfddns_config" | grep '"type":"A"'`" ];then
#echo 'debug load_config chk get ipv4'
		if [ -z "$get_ipv4_cmd" -a -z "$get_ipv4_url" ];then
			echo_date 'At least one of "get_ipv4_cmd" and "get_ipv4_url" is REQUIRED!'
			return 1
		fi
#echo 'debug load_config chk get ipv4 cmd = '"$get_ipv4_cmd"
#echo 'debug load_config chk get ipv4 url = '"$get_ipv4_url"
	fi
	get_ipv6_cmd=`echo "$cfddns_config" | $jq_path -r .get_ipv6_cmd`
	get_ipv6_url=`echo "$cfddns_config" | $jq_path -r .get_ipv6_url`
	if [ -n "`echo "$cfddns_config" | grep '"type":"AAAA"'`" ];then
#echo 'debug load_config chk get ipv6'
		if [ -z "$get_ipv6_cmd" -a -z "$get_ipv6_url" ];then
			echo_date 'At least one of "get_ipv6_cmd" and "get_ipv6_url" is REQUIRED!'
			return 1
		fi
#echo 'debug load_config chk get ipv6 cmd = '"$get_ipv6_cmd"
#echo 'debug load_config chk get ipv6 url = '"$get_ipv6_url"
	fi
	
#echo 'debug load_config chk_interval'
	check_interval=`echo "$cfddns_config" | $jq_path -r .check_interval | grep -oE "$number_regex"`
	if [ -z "$check_interval" -o "$check_interval" == "null" ];then
		check_interval=0
	fi
#echo 'debug load_config chk_interval = '"$check_interval"
	
	if [ -r "$CACHE_FILE" ];then
		cfddns_last_cache=`$jq_path -c . $CACHE_FILE`
		if [ -n "$cfddns_last_cache" ];then
#echo 'debug load_config cfddns_cache ok'
			chk_email=`echo "$cfddns_last_cache" | $jq_path -r .email`
			if [ -z "$chk_email" -o "$chk_email" == "null" -o "$user_email" != "$chk_email" ];then
				verify_account=-1
				cfddns_last_cache=""
			fi
		else
			:
#echo 'debug load_config cfddns_cache null'
		fi
	fi
	
	return 0
}

save_cache(){
#echo 'debug enter save_cache'
	if [ -z "$errors" ];then
		errors="none"
	fi
	cfddns_cache='{'$cfddns_cache'}'
	cfddns_status_cache='{'$cfddns_status_cache',"errors":"'$errors'","date":"'$(date +%YY%mM%dD\ %X)'"}'
	cache_test=`echo "$cfddns_cache" | $jq_path -c .`
	if [ -n "$cache_test" ];then
		echo "$cfddns_cache" | $jq_path . > $CACHE_FILE
	else
		echo_date 'Content of "cache" is not in json format'
		echo "$cfddns_cache"
#echo 'debug '"$cfddns_cache"
	fi
	cache_test=`echo "$cfddns_status_cache" | $jq_path -c .`
	if [ -n "$cache_test" ];then
		echo "$cfddns_status_cache" | $jq_path . > $STATUS_FILE
	else
		echo '{"errors":"Content of "status" is not in json format, check log for details"}' > $STATUS_FILE
		echo_date 'Content of "status" is not in json format'
		echo "$cfddns_status_cache"
	fi
}

load_cache(){ # $1=reference $2=key
#echo 'debug enter load_cache'
	if [ -z "$cfddns_last_cache" -o -z "$1" -o -z "$2" ];then
		return 1
	fi
#echo 'debug load_cache '"$1" "$2"
	refer=$1
	key=${2//./_}
	value=`echo "$cfddns_last_cache" | $jq_path -r .$key`
#echo 'debug load_cache refer = '"$refer" "$key" = "$value"
	if [ -n "$value" -a "$value" != "null" ];then
		eval $refer=$value
#echo 'debug load_cache final y '"$refer"' = '"$value"
		return 0
	else
		eval $refer=
#echo 'debug load_cache final n '"$refer"' = null'
	fi
	return 1
}

save_to_cache(){ # $1=key $2=value
#echo 'debug enter save_to_cache '"$1"
	key="${1//./_}"
	value="$2"
#echo 'debug save_to_cache key = '"$key"' value = '"$value"
	if [ -n "$cfddns_cache" ];then
		cfddns_cache=$cfddns_cache','
	fi
	stc_key_word=`echo "$key" | awk -F_ '{print $5}'`
#echo 'debug stc_key_word = '"$stc_key_word"
	if [ "$stc_key_word" == "ttl" -o "$stc_key_word" == "proxied" ];then
		cfddns_cache=$cfddns_cache'"'$key'":'$value
	else
		cfddns_cache=$cfddns_cache'"'$key'":"'$value'"'
	fi
	return 0
}

save_to_status_cache(){ # $1=key $2=value
#echo 'debug enter save_to_cache '"$1"
	key="${1//./_}"
	value="$2"
#echo 'debug save_to_cache key = '"$key"' value = '"$value"
	if [ -n "$cfddns_status_cache" ];then
		cfddns_status_cache="$cfddns_status_cache"','
	fi
	stc_key_word=`echo "$key" | awk -F_ '{print $5}'`
#echo 'debug stc_key_word = '"$stc_key_word"
	if [ "$stc_key_word" == "ttl" -o "$stc_key_word" == "proxied" ];then
		cfddns_status_cache="$cfddns_status_cache"'"'"$key"'":'"$value"
	else
		cfddns_status_cache="$cfddns_status_cache"'"'"$key"'":"'"$value"'"'
	fi
	return 0
}

reset_variables(){
#echo 'debug enter reset_variables'
	just_get_status=false
	cfddns_status_cache=""
	
	cfddns_config=""
	
	user_email=""
	global_api_key=""
	
	zone_id=""
	zone_name=""
	auto_create_zone=true
	zone_jump_start=false
	zone_type=full
	
	dns_record_id=""
	dns_record_type=""
	dns_record_name_prefix=""
	dns_record_full_name=""
	dns_record_content=""
	dns_record_ttl=0
	dns_record_proxied=false
	
	auto_create_record=false
	auto_delete_redundant_records=false
	
	load_zone=-1
	load_dns_record=-1
	
	g_auto_create_zone=true
	g_zone_jump_start=false
	g_zone_type=full
	g_auto_create_record=true
	g_auto_delete_redundant_records=false
	
	get_ipv4_cmd=""
	get_ipv4_url=""
	get_ipv6_cmd=""
	get_ipv6_url=""
	
	verify_zone=-1
	cf_zone_id=""
	cf_zone_name=""
	cf_record_id=""
	cf_record_prefix=""
	cf_record_type=""
	cf_record_content=""
	cf_record_ttl=0
	cf_record_proxied=false
		
	local_ipv4=""
	local_ipv6=""
	try_get_ipv4=0
	try_get_ipv6=0
	
	cfddns_cache=""
	cfddns_last_cache=""
	
	result_json=""
	result_errors=""
	result_messages=""
	
	errors=""
	
	get_ip_try_times=3
	get_ip_try_interval=10
}

save_errors(){ # $1=error message
	error="$1"
	if [ -n "$errors" ];then
		errors="$errors"';'
	fi
	errors="$errors""$error"
}


# 获取用户信息
api_get_user_detail(){
	curl -kLsX GET $base_url"user" \
		-H "X-Auth-Email: "$user_email \
		-H "X-Auth-Key: "$global_api_key \
		-H "Content-type: application/json"
}

# 获取zone信息
api_get_zone_detail(){
	curl -kLsX GET $base_url"zones/"$zone_id \
		-H "X-Auth-Email: "$user_email \
		-H "X-Auth-Key: "$global_api_key \
		-H "Content-type: application/json"
}

# 获取zone
api_get_zone(){
	curl -kLsX GET $base_url"zones?name="$zone_name"&status=active&direction=desc&match=all" \
		-H "X-Auth-Email: "$user_email \
		-H "X-Auth-Key: "$global_api_key \
		-H "Content-type: application/json"
}

# 创建zone
api_create_zone(){
	curl -kLsX POST $base_url"zones" \
		-H "X-Auth-Email: "$user_email \
		-H "X-Auth-Key: "$global_api_key \
		-H "Content-type: application/json" \
		--data '{"name":"'$zone_name'","jump_start":'$zone_jump_start',"type":"'$zone_type'"}'
}

# 删除zone
api_delete_zone(){
	curl -kLsX DELETE $base_url"zones/"$zone_id \
		-H "X-Auth-Email: "$user_email \
		-H "X-Auth-Key: "$global_api_key \
		-H "Content-type: application/json"
}

# 获取记录
api_get_dns_record(){
	curl -kLsX GET $base_url"zones/"$zone_id"/dns_records?type="$dns_record_type"&name="$dns_record_full_name"&direction=desc&match=all" \
		-H "X-Auth-Email: "$user_email \
		-H "X-Auth-Key: "$global_api_key \
		-H "Content-type: application/json"
}

# 更新记录
api_update_dns_record(){
	curl -kLsX PUT $base_url"zones/"$zone_id"/dns_records/"$dns_record_id \
		-H "X-Auth-Email: "$user_email \
		-H "X-Auth-Key: "$global_api_key \
		-H "Content-type: application/json" \
		--data '{"type":"'$dns_record_type'","name":"'$dns_record_full_name'","content":"'$dns_record_content'","ttl":'$dns_record_ttl',"proxied":'$dns_record_proxied'}'
}

# 创建记录
api_create_dns_record(){
	curl -kLsX POST $base_url"zones/"$zone_id"/dns_records" \
		-H "X-Auth-Email: "$user_email \
		-H "X-Auth-Key: "$global_api_key \
		-H "Content-type: application/json" \
		--data '{"type":"'$dns_record_type'","name":"'$dns_record_full_name'","content":"'$dns_record_content'","ttl":'$dns_record_ttl',"priority":0,"proxied":'$dns_record_proxied'}'
}

# 删除记录
api_delete_dns_record(){
	curl -kLsX DELETE $base_url"zones/"$zone_id"/dns_records/"$dns_record_id \
		-H "X-Auth-Email: "$user_email \
		-H "X-Auth-Key: "$global_api_key \
		-H "Content-type: application/json"
}


# 本地公网IP
get_local_ip(){ # $1=ip_version
#echo 'debug enter get_local_ip'
	get_ip_cmd_version=""
	get_ip_url_version=""
	ip_version="$1"
	if [ -z "$ip_version" ];then
		echo_date 'Missing IP version'
		return 1
	fi
	get_ip_cmd=""
	get_ip_url=""
	if [ $ip_version -eq 4 ];then
		try_get_ipv4=1
		get_ip_cmd="$get_ipv4_cmd"
		get_ip_url="$get_ipv4_url"
		get_ip_cmd_version=get_ipv4_cmd
		get_ip_url_version=get_ipv4_url
	elif [ $ip_version -eq 6 ];then
		try_get_ipv6=1
		get_ip_cmd="$get_ipv6_cmd"
		get_ip_url="$get_ipv6_url"
		get_ip_cmd_version=get_ipv6_cmd
		get_ip_url_version=get_ipv6_url
	else
		echo_date 'Wrong IP version, it must be 4 or 6'
		save_errors 'Wrong IP version, it must be 4 or 6'
		return 1
	fi
	if [ -z "$get_ip_cmd" -a -z "$get_ip_url" ];then
		echo_date 'Missing "'"$get_ip_cmd_version"'" and "'"$get_ip_url_version"'", at least one of "'"$get_ip_cmd_version"'" and "'"$get_ip_url_version"'" is required'
		save_errors '"'"$get_ip_cmd_version"'" and "'"$get_ip_url_version"'", at least one of "'"$get_ip_cmd_version"'" and "'"$get_ip_url_version"'" is required'
		return 1
	fi
	
	i=0
	while [ $i -le $get_ip_try_times ]
	do
		if [ $i -gt 0 ];then
			echo_date 'Retry in '"$get_ip_try_interval"' seconds'
			sleep $get_ip_try_interval
			echo_date 'Retry...'"$i"
		fi
		i=$(( $i + 1 ))
		local_ip=""
		if [ -n "$get_ip_cmd" ];then
			tmp=${get_ip_cmd//\\/};
			if [ $ip_version -eq 4 ];then
				local_ip=`eval $tmp | grep -oE "$ipv4_regex"`
				local_ipv4="$local_ip"
			else
				local_ip=`eval $tmp | grep -oE "$ipv6_regex"`
				local_ipv6="$local_ip"
			fi
			if [ -n "$local_ip" ];then
				echo_date 'Local IPv'"$ip_version"' by command is "'"$local_ip"'"'
				if [ $ip_version -eq 4 ];then
					save_to_cache local_ipv4 "$local_ipv4"
					save_to_status_cache local_ipv4 "$local_ipv4"
				else
					save_to_cache local_ipv6 "$local_ipv6"
					save_to_status_cache local_ipv6 "$local_ipv6"
				fi
				return 0
			else
				echo_date 'Failed to get IPv'"$ip_version"' by command'
			fi
		fi
		
		if [ -n "$get_ip_url" ];then
			if [ $ip_version -eq 4 ];then
				local_ip=`curl -s $get_ip_url | grep -oE "$ipv4_regex"`
				local_ipv4="$local_ip"
			else
				local_ip=`curl -s $get_ip_url | grep -oE "$ipv6_regex"`
				local_ipv6="$local_ip"
			fi
			if [ -n "$local_ip" ];then
				echo_date 'Local IPv'"$ip_version"' by url is "'"$local_ip"'"'
				if [ $ip_version -eq 4 ];then
					save_to_cache local_ipv4 "$local_ipv4"
					save_to_status_cache local_ipv4 "$local_ipv4"
				else
					save_to_cache local_ipv6 "$local_ipv6"
					save_to_status_cache local_ipv6 "$local_ipv6"
				fi
				return 0
			else
				echo_date 'Failed to get IPv'"$ip_version"' by url'
			fi
		fi
	done
	echo_date 'Failed to get IPv'"$ip_version"'. Please check "'"$get_ip_cmd_version"'" and "'"$get_ip_url_version"'"'
	save_errors 'Failed to get IPv'"$ip_version"'. Please check "'"$get_ip_cmd_version"'" and "'"$get_ip_url_version"'"'
	return 1
}



get_user_detail(){
#echo 'debug enter get_user_detail'
#echo 'debug user_email = '"$user_email"
#echo 'debug global_api_key = '"$global_api_key"
	echo_date 'Verifying user account'
	result_json=`api_get_user_detail | $jq_path -c .`
#echo "$result_json" | $jq_path .
	if [ -n "$result_json" -a "`echo "$result_json" | $jq_path -r .success`" == "true" ];then
		verify_account=1
		echo_date 'Succeed to verify user account'
		return 0
	else
		verify_account=0
		result_errors=`echo "$result_json" | $jq_path -c .errors`
		result_messages=`echo "$result_json" | $jq_path -c .messages`
		echo_date 'errors:'
		echo "$result_json" | $jq_path .errors
		echo_date 'messages:'
		echo "$result_json" | $jq_path .messages
		echo_date 'Failed to verify user account'
		save_errors 'Failed to verify user account, check log for details'
		return 1
	fi
}

get_zone_detail(){
#echo 'debug enter get_zone_detail'
#echo 'debug zone_id = '"$zone_id"
#echo 'debug zone_name = '"$zone_name"
	echo_date 'Verifying zone("'"$zone_name"'")'
	result_json=`api_get_zone_detail | $jq_path -c .`
#echo "$result_json" | $jq_path .
	if [ -n "$result_json" -a "`echo "$result_json" | $jq_path -r .success`" == "true" ];then
		verify_zone=1
		echo_date 'Succeed to verify zone("'"$zone_name"'")'
		return 0
	else
		verify_zone=0
		result_errors=`echo "$result_json" | $jq_path -c .errors`
		result_messages=`echo "$result_json" | $jq_path -c .messages`
		echo_date 'errors:'
		echo "$result_json" | $jq_path .errors
		echo_date 'messages:'
		echo "$result_json" | $jq_path .messages
		echo_date 'Failed to verify zone("'"$zone_name"'")'
		return 1
	fi
}

get_zone(){
#echo 'debug enter get_zone'
#echo 'debug zone_name = '"$zone_name"
	echo_date 'Getting zone("'"$zone_name"'")'
	result_json=`api_get_zone | $jq_path -c .`
#echo "$result_json" | $jq_path .
	if [ -n "$result_json" -a "`echo "$result_json" | $jq_path -r .success`" == "true" ];then
		zone_count=`echo "$result_json" | $jq_path -r .result_info.total_count`
		if [ $zone_count -eq 1 ];then
			zone_id=`echo "$result_json" | $jq_path -r .result[0].id`
			cf_zone_id=$zone_id
#echo 'debug zone_id = '"$zone_id"
#echo 'debug cf_zone_id = '"$cf_zone_id"
			echo_date 'Succeed to get zone("'"$zone_name"'")'
			return 0
		elif [ $zone_count -eq 0 ];then
			echo_date 'Zone("'"$zone_name"'") no found'
			save_errors 'Zone("'"$zone_name"'") no found'
			if [ "$just_get_status" == "true" ];then
				return 1
			fi
			return 2
		fi
	else
		result_errors=`echo "$result_json" | $jq_path -c .errors`
		result_messages=`echo "$result_json" | $jq_path -c .messages`
		echo_date 'errors:'
		echo "$result_json" | $jq_path .errors
		echo_date 'messages:'
		echo "$result_json" | $jq_path .messages
		echo_date 'Failed to get zone("'"$zone_name"'")'
		save_errors 'Failed to get zone("'"$zone_name"'"), check log for details'
		return 1
	fi
}

create_zone(){
#echo 'debug enter create_zone'
#echo 'debug zone_name = '"$zone_name"
#echo 'debug zone_jump_start = '"$zone_jump_start"
#echo 'debug zone_type = '"$zone_type"
	echo_date 'Creating zone("'"$zone_name"'")'
	result_json=`api_create_zone | $jq_path -c .`
#echo "$result_json" | $jq_path .
	if [ -n "$result_json" -a "`echo "$result_json" | $jq_path -r .success`" == "true" ];then
		zone_id=`echo "$result_json" | $jq_path -r .result.id`
		cf_zone_id=$zone_id
#echo 'debug zone_id = '"$zone_id"
#echo 'debug cf_zone_id = '"$cf_zone_id"
		sleep 5
		echo_date 'Succeed to create zone("'"$zone_name"'")'
		return 0
	else
		result_errors=`echo "$result_json" | $jq_path -c .errors`
		result_messages=`echo "$result_json" | $jq_path -c .messages`
		echo_date 'errors:'
		echo "$result_json" | $jq_path .errors
		echo_date 'messages:'
		echo "$result_json" | $jq_path .messages
		echo_date 'Failed to create zone("'"$zone_name"'")'
		return 1
	fi
}

delete_zone(){
#echo 'debug enter delete_zone'
	#zone_id=$cfddns_zone_id
	#zone_name=$cfddns_root_domain_name
#echo 'debug zone_id = '"$zone_id"
#echo 'debug zone_name = '"$zone_name"
	echo_date 'Deleting zone("'"$zone_name"'")'
	result_json=`api_delete_zone | $jq_path -c .`
#echo "$result_json" | $jq_path .
	if [ -n "$result_json" -a "`echo "$result_json" | $jq_path -r .success`" == "true" ];then
		zone_id=""
		cfddns_zone_id=""
		echo_date 'Succeed to delete zone("'"$zone_name"'")'
		return 0
	else
		result_errors=`echo "$result_json" | $jq_path -c .errors`
		result_messages=`echo "$result_json" | $jq_path -c .messages`
		echo_date 'errors:'
		echo "$result_json" | $jq_path .errors
		echo_date 'messages:'
		echo "$result_json" | $jq_path .messages
		echo_date 'Failed to delete zone("'"$zone_name"'")'
		return 1
	fi
}

get_dns_record(){
#echo 'debug enter get_dns_record'
#echo 'debug zone_id = '"$zone_id"
#echo 'debug zone_name = '"$zone_name"
#echo 'debug dns_record_type = '"$dns_record_type"
#echo 'debug dns_record_full_name = '"$dns_record_full_name"
	echo_date 'Getting DNS record(type="'"$dns_record_type"'", name="'"$dns_record_full_name"'")'
	result_json=`api_get_dns_record | $jq_path -c .`
#echo "$result_json" | $jq_path .
	if [ -n "$result_json" -a "`echo "$result_json" | $jq_path -r .success`" == "true" ];then
		total_count=`echo "$result_json" | $jq_path -r .result_info.total_count`
		if [ $total_count -gt 0 ];then
			cf_record_id=`echo "$result_json" | $jq_path -r .result[0].id`
			dns_record_id=$cf_record_id
			cf_record_content=`echo "$result_json" | $jq_path -r .result[0].content`
			cf_record_ttl=`echo "$result_json" | $jq_path -r .result[0].ttl`
			cf_record_proxied=`echo "$result_json" | $jq_path -r .result[0].proxied`
#echo 'debug cf_record_id = '"$cf_record_id"
#echo 'debug dns_record_id = '"$dns_record_id"
#echo 'debug cf_record_content = '"$cf_record_content"
#echo 'debug cf_record_ttl = '"$cf_record_ttl"
#echo 'debug cf_record_proxied = '"$cf_record_proxied"
			if [ $total_count -eq 1 ];then
				echo_date 'Succeed to get DNS record(type="'"$dns_record_type"'", name="'"$dns_record_full_name"'", content="'"$cf_record_content"'", ttl="'"$cf_record_ttl"'", proxied="'"$cf_record_proxied"'")'
				return 0
			elif [ "$auto_delete_redundant_records" == "false" ];then
				echo_date 'Type "'"$dns_record_type"'" DNS record of "'"$dns_record_full_name"'" is not unique, and the option "auto_delete_redundant_records" is "false", using the first DNS record'
				echo_date 'Succeed to get DNS record(type="'"$dns_record_type"'", name="'"$dns_record_full_name"'", content="'"$cf_record_content"'", ttl="'"$cf_record_ttl"'", proxied="'"$cf_record_proxied"'")'
				return 0
			else
				save_errors 'Type "'"$dns_record_type"'" DNS record of "'"$dns_record_full_name"'" is not unique'
				if [ "$just_get_status" == "true" ];then
					return 1
				fi
				return 3
			fi
		else
			echo_date 'DNS record(type="'"$dns_record_type"'", name="'"$dns_record_full_name"'") no found'
			save_errors 'DNS record(type="'"$dns_record_type"'", name="'"$dns_record_full_name"'") no found'
			if [ "$just_get_status" == "true" ];then
				return 1
			fi
			return 2
		fi
	else
		result_errors=`echo "$result_json" | $jq_path -c .errors`
		result_messages=`echo "$result_json" | $jq_path -c .messages`
		echo_date 'errors:'
		echo "$result_json" | $jq_path .errors
		echo_date 'messages:'
		echo "$result_json" | $jq_path .messages
		echo_date 'Failed to get DNS record(type="'"$dns_record_type"'", name="'"$dns_record_full_name"'")'
		save_errors 'Failed to get DNS record(type="'"$dns_record_type"'", name="'"$dns_record_full_name"'"), check log for details'
		return 1
	fi
}

update_dns_record(){
#echo 'debug enter update_dns_record'
#echo 'debug zone_id = '"$zone_id"
#echo 'debug zone_name = '"$zone_name"
#echo 'debug dns_record_id = '"$dns_record_id"
#echo 'debug dns_record_type = '"$dns_record_type"
#echo 'debug dns_record_full_name = '"$dns_record_full_name"
#echo 'debug dns_record_content = '"$dns_record_content"
#echo 'debug dns_record_ttl = '"$dns_record_ttl"
#echo 'debug dns_record_proxied = '"$dns_record_proxied"
	echo_date 'Updating DNS record(type="'"$dns_record_type"'", name="'"$dns_record_full_name"'", content="'"$cf_record_content"'", ttl="'"$cf_record_ttl"'", proxied="'"$cf_record_proxied"'")'
	result_json=`api_update_dns_record | $jq_path -c .`
#echo "$result_json" | $jq_path .
	if [ -n "$result_json" -a "`echo "$result_json" | $jq_path -r .success`" == "true" ];then
		echo_date 'Succeed to update DNS record(type="'"$dns_record_type"'", name="'"$dns_record_full_name"'", content="'"$cf_record_content"'", ttl="'"$cf_record_ttl"'", proxied="'"$cf_record_proxied"'")'
		echo_date '--to DNS record(type="'"$dns_record_type"'", name="'"$dns_record_full_name"'", content="'"$dns_record_content"'", ttl="'"$dns_record_ttl"'", proxied="'"$dns_record_proxied"'")'
		cf_record_content=$dns_record_content
		cf_record_ttl=$dns_record_ttl
		cf_record_proxied=$dns_record_proxied
#echo 'debug cf_record_content = '"$cf_record_content"
#echo 'debug cf_record_ttl = '"$cf_record_ttl"
#echo 'debug cf_record_proxied = '"$cf_record_proxied"
		return 0
	else
		result_errors=`echo "$result_json" | $jq_path -c .errors`
		result_messages=`echo "$result_json" | $jq_path -c .messages`
		echo_date 'errors:'
		echo "$result_json" | $jq_path .errors
		echo_date 'messages:'
		echo "$result_json" | $jq_path .messages
		echo_date 'Failed to update DNS record(type="'"$dns_record_type"'", name="'"$dns_record_full_name"'", content="'"$cf_record_content"'", ttl="'"$cf_record_ttl"'", proxied="'"$cf_record_proxied"'")'
		echo_date '--to DNS record(type="'"$dns_record_type"'", name="'"$dns_record_full_name"'", content="'"$dns_record_content"'", ttl="'"$dns_record_ttl"'", proxied="'"$dns_record_proxied"'")'
		return 1
	fi
}

create_dns_record(){
#echo 'debug enter create_dns_record'
#echo 'debug zone_id = '"$zone_id"
#echo 'debug zone_name = '"$zone_name"
#echo 'debug dns_record_type = '"$dns_record_type"
#echo 'debug dns_record_full_name = '"$dns_record_full_name"
#echo 'debug dns_record_ttl = '"$dns_record_ttl"
#echo 'debug dns_record_proxied = '"$dns_record_proxied"
	echo_date 'Creating DNS record(type="'"$dns_record_type"'", name="'"$dns_record_full_name"'", ttl="'"$dns_record_ttl"'", proxied="'"$dns_record_proxied"'")'
	result_json=`api_create_dns_record | $jq_path -c .`
#echo "$result_json" | $jq_path .
	if [ -n "$result_json" -a "`echo "$result_json" | $jq_path -r .success`" == "true" ];then
		dns_record_id=`echo "$result_json" | $jq_path -r .result.id`
		cf_record_id=$dns_record_id
		cf_record_type=$dns_record_type
		cf_record_content=$dns_record_content
		cf_record_ttl=$dns_record_ttl
		cf_record_proxied=$dns_record_proxied
#echo 'debug dns_record_id = '"$dns_record_id"
#echo 'debug cf_record_id = '"$cf_record_id"
#echo 'debug cf_record_type = '"$cf_record_type"
#echo 'debug cf_record_content = '"$cf_record_content"
#echo 'debug cf_record_ttl = '"$cf_record_ttl"
#echo 'debug cf_record_proxied = '"$cf_record_proxied"
		echo_date 'Succeed to create DNS record(type="'"$dns_record_type"'", name="'"$dns_record_full_name"'", ttl="'"$dns_record_ttl"'", proxied="'"$dns_record_proxied"'")'
		return 0
	else
		result_errors=`echo "$result_json" | $jq_path -c .errors`
		result_messages=`echo "$result_json" | $jq_path -c .messages`
		echo_date 'errors:'
		echo "$result_json" | $jq_path .errors
		echo_date 'messages:'
		echo "$result_json" | $jq_path .messages
		echo_date 'Failed to create DNS record(type="'"$dns_record_type"'", name="'"$dns_record_full_name"'", ttl="'"$dns_record_ttl"'", proxied="'"$dns_record_proxied"'")'
		return 1
	fi
}

delete_dns_record(){
#echo 'debug enter delete_dns_record'
	#zone_id=$cfddns_zone_id
	#dns_record_id=$cfddns_ipv4_record_id
#echo 'debug zone_id = '"$zone_id"
#echo 'debug zone_name = '"$zone_name"
#echo 'debug dns_record_id = '"$dns_record_id"
	echo_date 'Deleting DNS record(id="'"$dns_record_id"'", type="'"$dns_record_type"'", name="'"$dns_record_full_name"'", content="'"$dns_record_content"'", ttl="'"$dns_record_ttl"'", proxied="'"$dns_record_proxied"'")'
	delete_record_json=`api_delete_dns_record | $jq_path -c .`
#echo "$result_json" | $jq_path .
	if [ -n "$result_json" -a "`echo "$result_json" | $jq_path -r .success`" == "true" ];then
		dns_record_id=""
		echo_date 'Succeed to delete DNS record(id="'"$dns_record_id"'", type="'"$dns_record_type"'", name="'"$dns_record_full_name"'", content="'"$dns_record_content"'", ttl="'"$dns_record_ttl"'", proxied="'"$dns_record_proxied"'")'
		return 0
	else
		result_errors=`echo "$result_json" | $jq_path -c .errors`
		result_messages=`echo "$result_json" | $jq_path -c .messages`
		echo_date 'errors:'
		echo "$result_json" | $jq_path .errors
		echo_date 'messages:'
		echo "$result_json" | $jq_path .messages
		echo_date 'Failed to delete DNS record(id="'"$dns_record_id"'", type="'"$dns_record_type"'", name="'"$dns_record_full_name"'", content="'"$dns_record_content"'", ttl="'"$dns_record_ttl"'", proxied="'"$dns_record_proxied"'")'
		return 1
	fi
}


verify_user_info(){
#echo 'debug enter verify_user_info'
	if [ $verify_account -eq -1 ];then
#echo 'debug enter verify_account'
		get_user_detail
		if [ $? -ne 0 ];then
			return 1
		fi
	fi
	
	return 0
}

verify_zone_info(){
#echo 'debug enter verify_zone_info'
	if [ $verify_zone -eq -1 ];then
#echo 'debug enter verify_zone'
		get_zone_detail
		if [ $? -ne 0 ];then
			return 1
		fi
	fi
	
	return 0
}

get_info(){
#echo 'debug enter get_info'
	if [ $load_zone -ne 1 ];then
#echo 'debug enter load_zone'
		res=-1
		for try_times in 0 1 2 3
		do
			if [ $try_times -gt 0 ];then
				echo_date Retry in 10 seconds
				sleep 10
				echo_date Retry...$try_times
			fi
			
			get_zone
			res=$?
			if [ $res -eq 0 ];then
				load_zone=1
				verify_zone=1
				save_to_cache "$zone_name.id" "$zone_id"
				break
			elif [ $res -eq 2 ];then
				if [ "$auto_create_zone" == "true" ];then
					echo_date The option \"auto_create_zone\" is \"true\", creating zone\(\"$zone_name\"\)
					create_zone
					if [ $? -ne 0 ];then
						load_zone=0
						return 1
					fi
					load_zone=1
					verify_zone=1
					save_to_cache "$zone_name.id" "$zone_id"
					res=0
					break
				else
					echo_date The option \"auto_create_zone\" is \"false\", skipping updating DNS records of zone\(\"$zone_name\"\)
					load_zone=0
					return 1
				fi
			fi
		done
		
		if [ $res -ne 0 ];then
			load_zone=0
			return 1
		fi
	fi
	
	if [ $load_dns_record -ne 1 ];then
#echo 'debug enter load_dns_record'
		res=-1
		for try_times in 0 1 2 3
		do
			if [ $try_times -gt 0 ];then
				echo_date Retry in 10 seconds
				sleep 10
				echo_date Retry...$try_times
			fi
			
			get_dns_record
			res=$?
			if [ $res -eq 0 ];then
				load_dns_record=1
				break
			elif [ $res -eq 2 ];then
				if [ "$auto_create_record" == "true" ];then
					echo_date The option \"auto_create_record\" is \"true\", creating DNS record\(type=\"$dns_record_type\", name=\"$dns_record_full_name\", ttl=\"$dns_record_ttl\", proxied=\"$dns_record_proxied\"\) for zone\(\"$zone_name\"\)
					create_dns_record
					if [ $? -ne 0 ];then
						load_dns_record=0
						return 1
					fi
					load_dns_record=1
					return 2
				else
					echo_date The option \"auto_create_record\" is \"false\", skipping updating DNS record\(type=\"$dns_record_type\", name=\"$dns_record_full_name\"\) for zone\(\"$zone_name\"\)
					load_dns_record=0
					return 1
				fi
			elif [ $res -eq 3 ];then
				echo_date Type \"$dns_record_type\" DNS record of \"$dns_record_full_name\" is not unique, and the option \"auto_delete_redundant_records\" is \"true\", using the first DNS record, deleting others
				tmp_record_content=$dns_record_content
				tmp_record_ttl=$dns_record_ttl
				tmp_record_proxied=$dns_record_proxied
				i=0
				while true
				do
					i=$(( $i + 1 ))
					tmp_record_info=`echo "$result_json" | $jq_path -c .result[$i]`
					if [ -z "$tmp_record_info" -o "$tmp_record_info" == "null" ];then
						if [ $i -gt 1 ];then
							dns_record_id=`echo "$result_json" | $jq_path -r .result[0].id`
							dns_record_content=$tmp_record_content
							dns_record_ttl=$tmp_record_ttl
							dns_record_proxied=$tmp_record_proxied
						fi
						break
					fi
					dns_record_id=`echo "$tmp_record_info" | $jq_path -r .id`
					dns_record_content=`echo "$tmp_record_info" | $jq_path -r .content`
					dns_record_ttl=`echo "$tmp_record_info" | $jq_path -r .ttl`
					dns_record_proxied=`echo "$tmp_record_info" | $jq_path -r .proxied`
					delete_dns_record
				done
				return 0
			fi
		done
		
		if [ $res -ne 0 ];then
			load_dns_record=0
			return 1
		fi
	fi
	
	
	return 0
}


	#cat > $STATUS_FILE <<-EOF
	#{"local_ipv4":"$local_ipv4","cf_ipv4":"$cf_ipv4","local_ipv6":"$local_ipv6","cf_ipv6":"$cf_ipv6","error":"none","date":"$(date +%Y年%m月%d日\ %X)"}
	#EOF

get_status(){
	rm -rf $STATUS_FILE
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
	cat > $STATUS_FILE <<-EOF
	{"local_ipv4":"$local_ipv4","cf_ipv4":"$cf_ipv4","local_ipv6":"$local_ipv6","cf_ipv6":"$cf_ipv6","error":"none","date":"$(date +%Y年%m月%d日\ %X)"}
	EOF
}

# 执行更新
do_start(){
#echo 'debug enter do_start'
#show_memory
	if [ -z "$jq_path" ];then
#echo 'debug jq_path = '"$jq_path"
		echo_date 'Missing "jq" dependency package, program can not run, please install "jq" dependency package firstly'
		exit 1
	fi
	first=1
	while true
	do
		if [ $first -ne 1 ];then
			if [ $check_interval -gt 0 ];then
				echo_date 'Check again after '"$check_interval"' seconds'
				sleep $check_interval
			else
				break
			fi
		else
			first=0
		fi
#echo 'debug enter loop'

		load_config
		res=$?
		if [ $res -ne 0 ];then
			#echo "$cfddns_config"
			exit 1
		fi
		save_to_cache email "$user_email"
		if [ "$just_get_status" == "false" ];then
			
			g_auto_create_zone=`echo "$cfddns_config" | $jq_path -r .auto_create_zone`
			if [ "$g_auto_create_zone" != "false" ];then
				g_auto_create_zone=true
			fi
			g_zone_jump_start=`echo "$cfddns_config" | $jq_path -r .auto_create_zone_jump_start`
			if [ "$g_zone_jump_start" != "true" ];then
				g_zone_jump_start=false
			fi
			g_zone_type=`echo "$cfddns_config" | $jq_path -r .auto_create_zone_type`
			if [ "$g_zone_type" != "partial" ];then
				g_zone_type=full
			fi
			g_auto_create_record=`echo "$cfddns_config" | $jq_path -r .auto_create_record`
			if [ "$g_auto_create_record" != "false" ];then
				g_auto_create_record=true
			fi
			g_auto_delete_redundant_records=`echo "$cfddns_config" | $jq_path -r .auto_delete_redundant_records`
			if [ "$g_auto_delete_redundant_records" != "true" ];then
				g_auto_delete_redundant_records=false
			fi
		fi
		
		
		i=-1
		while true
		do
			if [ $verify_account -eq 0 ];then
				break
			fi
			i=$(( $i + 1 ))
#echo 'debug i = '"$i"
			load_zone=-1
			tmp_domain=`echo "$cfddns_config" | $jq_path -c .domains[$i]`
			if [ -z "$tmp_domain" -o "$tmp_domain" == "null" ];then
				break
			fi
#echo 'debug enter domains loop'
			
			verify_zone=-1
			zone_name=`echo "$tmp_domain" | $jq_path -r .root_domain_name`
			
			if [ "$just_get_status" == "false" ];then
				auto_create_zone=`echo "$tmp_domain" | $jq_path -r .auto_create_zone`
				if [ "$auto_create_zone" == "null" ];then
					auto_create_zone=$g_auto_create_zone
				elif [ "$auto_create_zone" != "false" ];then
					auto_create_zone=true
				fi
				zone_jump_start=`echo "$tmp_domain" | $jq_path -r .auto_create_zone_jump_start`
				if [ "$zone_jump_start" == "null" ];then
					zone_jump_start=g_zone_jump_start
				elif [ "$zone_jump_start" != "true" ];then
					zone_jump_start=false
				fi
				zone_type=`echo "$tmp_domain" | $jq_path -r .auto_create_zone_type`
				if [ "$zone_type" == "null" ];then
					zone_type=$g_zone_type
				elif [ "$zone_type" != "partial" ];then
					zone_type=full
				fi
			fi
			
			if [ -n "$zone_name" ];then
				load_cache zone_id $zone_name.id
				res=$?
				if [ $res -eq 0 -a "$just_get_status" == "false" ];then
					load_zone=1
					cf_zone_id=$zone_id
					save_to_cache "$zone_name.id" "$zone_id"
				fi
			else
				echo_date '"root_domain_name" is required but empty, skipping this root domain name'
				save_errors '"root_domain_name" is required but the "root_domain_name" of domains '"$(( $i + 1 ))"' is empty'
				continue
			fi
			
			j=-1
			while true
			do
				if [ $verify_account -eq 0 -o $load_zone -eq 0 ];then
					break
				fi
#echo 'debug enter hosts loop'
				j=$(( $j + 1 ))
#echo 'debug j = '"$j"
				tmp_host=`echo "$tmp_domain" | $jq_path -c .hosts[$j]`
				if [ -z "$tmp_host" -o "$tmp_host" == "null" ];then
					break
				fi
				dns_record_name_prefix=`echo "$tmp_host" | $jq_path -r .subdomain_name_prefix`
				cf_record_prefix=$dns_record_name_prefix
				if [ -z "$dns_record_name_prefix" ];then
					dns_record_full_name=$zone_name
				else
					dns_record_full_name=$dns_record_name_prefix.$zone_name
				fi
				
				
				
				
				
				k=-1
				while true
				do
					if [ $verify_account -eq 0 -o $load_zone -eq 0 ];then
						break
					fi
					k=$(( $k + 1 ))
#echo 'debug k = '"$k"
					load_dns_record=-1
					tmp_record=`echo "$tmp_host" | $jq_path -c .records[$k]`
					if [ -z "$tmp_record" -o "$tmp_record" == "null" ];then
						break
					fi
#echo 'debug enter dns record loop'
					dns_record_type=`echo "$tmp_record" | $jq_path -r .type`
					if [ "$dns_record_type" == "A" ];then
						if [ $try_get_ipv4 -eq 0 ];then
							get_local_ip 4
							res=$?
							if [ "$just_get_status" == "false" ];then
								if [ $res -ne 0 ];then
									local_ipv4=""
									continue
								fi
							fi
						fi
						if [ "$just_get_status" == "false" ];then
							if [ -n "$local_ipv4" ];then
								dns_record_content=`echo "$tmp_record" | $jq_path -r .content | grep -oE "$ipv4_regex"`
								if [ -z "$dns_record_content" ];then
									dns_record_content=$local_ipv4
								fi
							else
								continue
							fi
						fi
					elif [ "$dns_record_type" == "AAAA" ];then
						if [ $try_get_ipv6 -eq 0 ];then
							get_local_ip 6
							res=$?
							if [ "$just_get_status" == "false" ];then
								if [ $res -ne 0 ];then
									local_ipv6=""
									continue
								fi
							fi
						fi
						if [ "$just_get_status" == "false" ];then
							if [ -n "$local_ipv6" ];then
								dns_record_content=`echo "$tmp_record" | $jq_path -r .content | grep -oE "$ipv6_regex"`
								if [ -z "$dns_record_content" ];then
									dns_record_content=$local_ipv6
								fi
							else
								continue
							fi
						fi
					else
						echo_date 'DNS record type of "'"$dns_record_full_name"'" error'
						save_errors 'DNS record type of "'"$dns_record_full_name"'" error'
						continue
					fi
					cf_record_type=$dns_record_type
					if [ "$just_get_status" == "false" ];then
						dns_record_ttl=`echo "$tmp_record" | $jq_path -r .ttl`
						if [ $dns_record_ttl -ne 1 -a $dns_record_ttl -ne 120 -a $dns_record_ttl -ne 300 -a $dns_record_ttl -ne 600 -a $dns_record_ttl -ne 900 -a $dns_record_ttl -ne 1800 -a $dns_record_ttl -ne 3600 -a $dns_record_ttl -ne 7200 -a $dns_record_ttl -ne 18000 -a $dns_record_ttl -ne 43200 -a $dns_record_ttl -ne 86400 ];then
							dns_record_ttl=1
						fi
						dns_record_proxied=`echo "$tmp_record" | $jq_path -r .proxied`
						if [ "$dns_record_proxied" != "true" ];then
							dns_record_proxied=false
						fi
						
						auto_create_record=`echo "$tmp_record" | $jq_path -r .auto_create_record`
						if [ "$auto_create_record" == "null" ];then
							auto_create_record=$g_auto_create_record
						elif [ "$auto_create_record" != "false" ];then
							auto_create_record=true
						fi
						auto_delete_redundant_records=`echo "$tmp_record" | $jq_path -r .auto_delete_redundant_records`
						if [ "$auto_delete_redundant_records" == "null" ];then
							auto_delete_redundant_records=$g_auto_delete_redundant_records
						elif [ "$auto_delete_redundant_records" != "true" ];then
							auto_delete_redundant_records=false
						fi
						
						
						load_cache cf_record_id $zone_name.$dns_record_name_prefix.$dns_record_type.id
						res1=$?
	#echo debug res1 = $res1
						load_cache cf_record_content $zone_name.$dns_record_name_prefix.$dns_record_type.content
						res2=$?
	#echo debug res2 = $res2
						load_cache cf_record_ttl $zone_name.$dns_record_name_prefix.$dns_record_type.ttl
						res3=$?
	#echo debug res3 = $res3
						load_cache cf_record_proxied $zone_name.$dns_record_name_prefix.$dns_record_type.proxied
						res4=$?
	#echo debug res4 = $res4
						if [ $res1 -eq 0 -a $res2 -eq 0 -a $res3 -eq 0 -a $res4 -eq 0 ];then
							dns_record_id=$cf_record_id
							load_dns_record=1
						fi
					fi
					
					
					res=-1
					if [ $load_zone -ne 1 -o $load_dns_record -ne 1 ];then
						if [ $verify_account -eq -1 ];then
							verify_user_info
							res=$?
							if [ $res -ne 0 ];then
								break
							fi
						fi
						if [ "$just_get_status" == "true" ];then
							if [ -n "$zone_id" -a $verify_zone -eq -1 ];then
								verify_zone_info
								res=$?
								if [ $res -eq 0 ];then
									load_zone=1
									cf_zone_id=$zone_id
									save_to_cache "$zone_name.id" "$zone_id"
								fi
							fi
						fi
						
						get_info
						res=$?
						if [ $res -ne 0 -a $res -ne 2 ];then
							continue
						fi
					fi
					
					
					
#echo 'debug dns_record_content = '"$dns_record_content"
#echo 'debug cf_record_content = '"$cf_record_content"
#echo 'debug dns_record_ttl = '"$dns_record_ttl"
#echo 'debug cf_record_ttl = '"$cf_record_ttl"
#echo 'debug dns_record_proxied = '"$dns_record_proxied"
#echo 'debug cf_record_proxied = '"$cf_record_proxied"
					if [ $res -eq 2 -o "$just_get_status" == "true" ];then
						:
					elif [ "$dns_record_content" != "$cf_record_content" -o $dns_record_ttl -ne $cf_record_ttl -o "$dns_record_proxied" != "$cf_record_proxied" ];then
						echo_date '"Content/TTL/proxied" on Cloudflare is different from the local, updating type "'"$dns_record_type"'" records for "'"$dns_record_full_name"'"'
						echo_date 'dns_record_content = "'"$dns_record_content"'"'
						echo_date 'cf_record_content = "'"$cf_record_content"'"'
						echo_date 'dns_record_ttl = "'"$dns_record_ttl"'"'
						echo_date 'cf_record_ttl = "'"$cf_record_ttl"'"'
						echo_date 'dns_record_proxied = "'"$dns_record_proxied"'"'
						echo_date 'cf_record_proxied = "'"$cf_record_proxied"'"'
						if [ $verify_account -eq -1 ];then
							verify_user_info
							res=$?
							if [ $res -ne 0 ];then
								break
							fi
						fi
						
						update_dns_record
						res=$?
						if [ $res -ne 0 ];then
							if [ -n "`echo "$result_errors" | grep "Invalid zone identifier"`" ];then
								echo_date 'Zone id got from the cache is invalid, getting from Cloudflare and try again'
								load_zone=-1
								k=$(( $k - 1 ))
#echo 'debug cfddns_last_cache = '"$cfddns_last_cache"
								cfddns_last_cache=${cfddns_last_cache//$zone_id/}
								cfddns_last_cache=${cfddns_last_cache//$dns_record_id/}
#echo 'debug cfddns_last_cache = '"$cfddns_last_cache"
								zone_id=""
								cf_zone_id=""
								dns_record_id=""
								cf_record_id=""
								result_errors=""
								result_messages=""
							elif [ -n "`echo "$result_errors" | grep "Invalid DNS record identifier"`" ];then
								echo_date 'DNS record id got from the cache is invalid, getting from Cloudflare and try again'
								k=$(( $k - 1 ))
#echo 'debug cfddns_last_cache = '"$cfddns_last_cache"
								cfddns_last_cache=${cfddns_last_cache//$dns_record_id/}
#echo 'debug cfddns_last_cache = '"$cfddns_last_cache"
								dns_record_id=""
								cf_record_id=""
								result_errors=""
								result_messages=""
							fi
							continue
						fi
					else
						echo_date 'No need to update type "'"$dns_record_type"'" records for "'"$dns_record_full_name"'"'
					fi
					save_to_cache "$zone_name.$cf_record_prefix.$cf_record_type.id" "$cf_record_id"
					save_to_cache "$zone_name.$cf_record_prefix.$cf_record_type.content" "$cf_record_content"
					save_to_cache "$zone_name.$cf_record_prefix.$cf_record_type.ttl" "$cf_record_ttl"
					save_to_cache "$zone_name.$cf_record_prefix.$cf_record_type.proxied" "$cf_record_proxied"
					
					save_to_status_cache "$zone_name.$cf_record_prefix.$cf_record_type.content" "$cf_record_content"
					save_to_status_cache "$zone_name.$cf_record_prefix.$cf_record_type.ttl" "$cf_record_ttl"
					save_to_status_cache "$zone_name.$cf_record_prefix.$cf_record_type.proxied" "$cf_record_proxied"
#show_memory
				done
			done
		done
		save_cache
		reset_variables
#show_memory
	done
	
}

do_stop(){
	if [ $pid_col -ne 0 ];then
		tmp_cmd="$process_list_cmd | grep \"$0\" | grep -v grep | awk '{print \$$pid_col}'"
#echo 'debug $tmp_cmd'
		#tmp_cmd1="$process_list_cmd | grep \"$0\" | grep -v grep"
		#echo 'pid = '"$$"
		#echo "`eval $tmp_cmd1`"
		for pid in `eval $tmp_cmd`
		do
			if [ $pid -lt $(( $$ - 1 )) ];then
				echo_date 'kill pid '"$pid"
				kill -9 $pid
			fi
		done
	fi
}

case $1 in
startup)
	get_ip_try_times=12
	get_ip_try_interval=300
	do_start >> $LOG_FILE
	;;
start)
	do_stop >> $LOG_FILE
	do_start >> $LOG_FILE
	;;
stop)
	do_stop >> $LOG_FILE
	;;
status)
	just_get_status=true
	check_interval=0
	do_start >> $LOG_FILE
	;;
*)
	echo usage:
	echo -e "\t"$0 start/stop
	;;
esac