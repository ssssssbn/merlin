<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
	<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta HTTP-EQUIV="Pragma" CONTENT="no-cache" />
	<meta HTTP-EQUIV="Expires" CONTENT="-1" />
	<link rel="shortcut icon" href="images/favicon.png" />
	<link rel="icon" href="images/favicon.png" />
	<title>软件中心 - Cfddns</title>
	<link rel="stylesheet" type="text/css" href="index_style.css" />
	<link rel="stylesheet" type="text/css" href="form_style.css" />
	<link rel="stylesheet" type="text/css" href="usp_style.css" />
	<link rel="stylesheet" type="text/css" href="ParentalControl.css">
	<link rel="stylesheet" type="text/css" href="css/icon.css">
	<link rel="stylesheet" type="text/css" href="css/element.css">
	<script type="text/javascript" src="/state.js"></script>
	<script type="text/javascript" src="/popup.js"></script>
	<script type="text/javascript" src="/help.js"></script>
	<script type="text/javascript" src="/validator.js"></script>
	<script type="text/javascript" src="/js/jquery.js"></script>
	<script type="text/javascript" src="/general.js"></script>
	<script type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
	<script language="JavaScript" type="text/javascript" src="/client_function.js"></script>
	<script type="text/javascript" src="/dbconf?p=cfddns_&v=<% uptime(); %>"></script>
	<script>
		var $j = jQuery.noConflict();
		var get_satus_try_times = 0;
		function init() {
			show_menu(menu_hook);
			buildswitch();
			var rrt = document.getElementById("switch_main");
			if (document.form.cfddns_enable.value != "true") {
				rrt.checked = false;
				//$j("#cfddns_table_config").hide();
			} else {
				rrt.checked = true;
				$j("#cfddns_table_config").show();
			}
			rrt = document.getElementById("switch_cfddns_auto_create_zone");
			if (document.form.cfddns_auto_create_zone.value != "true") {
				rrt.checked = false;
				$j("#tr_cfddns_auto_create_zone_jump_start").hide();
				$j("#tr_cfddns_auto_create_zone_type").hide();
			} else {
				rrt.checked = true;
				$j("#tr_cfddns_auto_create_zone_jump_start").show();
				$j("#tr_cfddns_auto_create_zone_type").show();
			}
			rrt = document.getElementById("switch_cfddns_auto_create_zone_jump_start");
			if (document.form.cfddns_auto_create_zone_jump_start.value != "true") {
				rrt.checked = false;
			} else {
				rrt.checked = true;
			}
			rrt = document.getElementById("switch_cfddns_detailed_config");
			if (document.form.cfddns_detailed_config.value != "true") {
				rrt.checked = false;
				$j("#tr_cfddns_ttl").show();
				$j("#tr_cfddns_proxied").show();
				$j("#tr_cfddns_auto_create_record").show();
				$j("#tr_cfddns_auto_delete_redundant_records").show();
				$j("#tr_cfddns_ipv4_ttl").hide();
				$j("#tr_cfddns_ipv4_proxied").hide();
				$j("#tr_cfddns_ipv4_auto_create_record").hide();
				$j("#tr_cfddns_ipv4_auto_delete_redundant_records").hide();
				$j("#tr_cfddns_ipv6_ttl").hide();
				$j("#tr_cfddns_ipv6_proxied").hide();
				$j("#tr_cfddns_ipv6_auto_create_record").hide();
				$j("#tr_cfddns_ipv6_auto_delete_redundant_records").hide();
			} else {
				rrt.checked = true;
				$j("#tr_cfddns_ttl").hide();
				$j("#tr_cfddns_proxied").hide();
				$j("#tr_cfddns_auto_create_record").hide();
				$j("#tr_cfddns_auto_delete_redundant_records").hide();
				$j("#tr_cfddns_ipv4_ttl").show();
				$j("#tr_cfddns_ipv4_proxied").show();
				$j("#tr_cfddns_ipv4_auto_create_record").show();
				$j("#tr_cfddns_ipv4_auto_delete_redundant_records").show();
				$j("#tr_cfddns_ipv6_ttl").show();
				$j("#tr_cfddns_ipv6_proxied").show();
				$j("#tr_cfddns_ipv6_auto_create_record").show();
				$j("#tr_cfddns_ipv6_auto_delete_redundant_records").show();
			}
			rrt = document.getElementById("switch_cfddns_proxied");
			if (document.form.cfddns_proxied.value != "true") {
				rrt.checked = false;
			} else {
				rrt.checked = true;
			}
			rrt = document.getElementById("switch_cfddns_auto_create_record");
			if (document.form.cfddns_auto_create_record.value != "true") {
				rrt.checked = false;
			} else {
				rrt.checked = true;
			}
			rrt = document.getElementById("switch_cfddns_auto_delete_redundant_records");
			if (document.form.cfddns_auto_delete_redundant_records.value != "true") {
				rrt.checked = false;
			} else {
				rrt.checked = true;
			}
			rrt = document.getElementById("switch_cfddns_ipv4_proxied");
			if (document.form.cfddns_ipv4_proxied.value != "true") {
				rrt.checked = false;
			} else {
				rrt.checked = true;
			}
			rrt = document.getElementById("switch_cfddns_ipv4_auto_create_record");
			if (document.form.cfddns_ipv4_auto_create_record.value != "true") {
				rrt.checked = false;
			} else {
				rrt.checked = true;
			}
			rrt = document.getElementById("switch_cfddns_ipv4_auto_delete_redundant_records");
			if (document.form.cfddns_ipv4_auto_delete_redundant_records.value != "true") {
				rrt.checked = false;
			} else {
				rrt.checked = true;
			}
			rrt = document.getElementById("switch_cfddns_ipv6_proxied");
			if (document.form.cfddns_ipv6_proxied.value != "true") {
				rrt.checked = false;
			} else {
				rrt.checked = true;
			}
			rrt = document.getElementById("switch_cfddns_ipv6_auto_create_record");
			if (document.form.cfddns_ipv6_auto_create_record.value != "true") {
				rrt.checked = false;
			} else {
				rrt.checked = true;
			}
			rrt = document.getElementById("switch_cfddns_ipv6_auto_delete_redundant_records");
			if (document.form.cfddns_ipv6_auto_delete_redundant_records.value != "true") {
				rrt.checked = false;
			} else {
				rrt.checked = true;
			}


			$j("#cfddns_user_email").val(db_cfddns_["cfddns_user_email"]);//使用邮箱
			$j("#cfddns_global_api_key").val(db_cfddns_["cfddns_global_api_key"]);//用户全局密钥
			$j("#cfddns_subdomain_name_prefix").val(db_cfddns_["cfddns_subdomain_name_prefix"]);//域名前缀
			$j("#cfddns_root_domain_name").val(db_cfddns_["cfddns_root_domain_name"]);//域名后缀
			//$j("#cfddns_auto_create_zone").val(db_cfddns_["cfddns_auto_create_zone"]);//自动创建域NS记录
			if(["true", "false"].indexOf($j("#cfddns_auto_create_zone").val()) == -1){
				$j("#cfddns_auto_create_zone").val(true);
			}
			//$j("#cfddns_auto_create_zone_jump_start").val(db_cfddns_["cfddns_auto_create_zone_jump_start"]);//自动尝试获取现有DNS记录
			if(["true", "false"].indexOf($j("#cfddns_auto_create_zone_jump_start").val()) == -1){
				$j("#cfddns_auto_create_zone_jump_start").val(false);
			}
			$j("#cfddns_auto_create_zone_type").val(db_cfddns_["cfddns_auto_create_zone_type"]);//托管类型
			if($j("#cfddns_auto_create_zone_type").val() == null){
				$j("#cfddns_auto_create_zone_type").val("full");
				//alert($j("#cfddns_auto_create_zone_type").val());
			}
			$j("#cfddns_update_object").val(db_cfddns_["cfddns_update_object"]);//更新对象(ipv4、ipv6、both)
			if(["ipv4", "ipv6", "both"].indexOf($j("#cfddns_update_object").val()) == -1){
				$j("#cfddns_update_object").val("ipv4");
			}
			//$j("#cfddns_detailed_config").val(db_cfddns_["cfddns_detailed_config"]);//详细配置
			if(["true", "false"].indexOf($j("#cfddns_detailed_config").val()) == -1){
				$j("#cfddns_detailed_config").val(false);
			}
			$j("#cfddns_ttl").val(db_cfddns_["cfddns_ttl"]);//生存时间
			if(!isNumber($j("#cfddns_ttl").val())){
				$j("#cfddns_ttl").val(1);
			}
			//$j("#cfddns_proxied").val(db_cfddns_["cfddns_proxied"]);//代理
			if(["true", "false"].indexOf($j("#cfddns_proxied").val()) == -1){
				$j("#cfddns_proxied").val(false);
			}
			//$j("#cfddns_auto_create_record").val(db_cfddns_["cfddns_auto_create_record"]);//自动创建记录
			if(["true", "false"].indexOf($j("#cfddns_auto_create_record").val()) == -1){
				$j("#cfddns_auto_create_record").val(true);
			}
			//$j("#cfddns_auto_delete_redundant_records").val(db_cfddns_["cfddns_auto_delete_redundant_records"]);//自动删除冗余记录
			if(["true", "false"].indexOf($j("#cfddns_auto_delete_redundant_records").val()) == -1)
				$j("#cfddns_auto_delete_redundant_records").val(false);
			$j("#cfddns_ipv4_ttl").val(db_cfddns_["cfddns_ipv4_ttl"]);//生存时间
			if(!isNumber($j("#cfddns_ipv4_ttl").val())){
				$j("#cfddns_ipv4_ttl").val(1);
			}
			//$j("#cfddns_ipv4_proxied").val(db_cfddns_["cfddns_ipv4_proxied"]);//代理
			if(["true", "false"].indexOf($j("#cfddns_ipv4_proxied").val()) == -1){
				$j("#cfddns_ipv4_proxied").val(false);
			}
			//$j("#cfddns_ipv4_auto_create_record").val(db_cfddns_["cfddns_ipv4_auto_create_record"]);//自动创建ipv4记录
			if(["true", "false"].indexOf($j("#cfddns_ipv4_auto_create_record").val()) == -1){
				$j("#cfddns_ipv4_auto_create_record").val(true);
			}
			//$j("#cfddns_ipv4_auto_delete_redundant_records").val(db_cfddns_["cfddns_ipv4_auto_delete_redundant_records"]);//自动删除冗余记录
			if(["true", "false"].indexOf($j("#cfddns_ipv4_auto_delete_redundant_records").val()) == -1)
				$j("#cfddns_ipv4_auto_delete_redundant_records").val(false);
			$j("#cfddns_ipv6_ttl").val(db_cfddns_["cfddns_ipv6_ttl"]);//生存时间
			if(!isNumber($j("#cfddns_ipv6_ttl").val())){
				$j("#cfddns_ipv6_ttl").val(1);
			}
			//$j("#cfddns_ipv6_proxied").val(db_cfddns_["cfddns_ipv6_proxied"]);//代理
			if(["true", "false"].indexOf($j("#cfddns_ipv6_proxied").val()) == -1){
				$j("#cfddns_ipv6_proxied").val(false);
			}
			//$j("#cfddns_ipv6_auto_create_record").val(db_cfddns_["cfddns_ipv6_auto_create_record"]);//自动创建ipv6记录
			if(["true", "false"].indexOf($j("#cfddns_ipv6_auto_create_record").val()) == -1){
				$j("#cfddns_ipv6_auto_create_record").val(true);
			}
			//$j("#cfddns_ipv6_auto_delete_redundant_records").val(db_cfddns_["cfddns_ipv6_auto_delete_redundant_records"]);//自动删除冗余记录
			if(["true", "false"].indexOf($j("#cfddns_ipv6_auto_delete_redundant_records").val()) == -1)
				$j("#cfddns_ipv6_auto_delete_redundant_records").val(false);
			//$j("#cfddns_cf_ipv6_content").val(db_cfddns_["cfddns_cf_ipv6_content"]);
			//$j("#cfddns_cf_ipv6_ttl").val(db_cfddns_["cfddns_cf_ipv6_ttl"]);
			//$j("#cfddns_cf_ipv6_proxied").val(db_cfddns_["cfddns_cf_ipv6_proxied"]);
			//$j("#cfddns_get_ipv4_cmd").val(db_cfddns_["cfddns_get_ipv4_cmd"]);//获得IPv4的命令
			//$j("#cfddns_get_ipv4_cmd").val($j("#cfddns_get_ipv4_cmd").val().replace(/\|/g,"\\\|").replace(/\$/g,"\\\$").replace(/'/g,"\\\'").replace(/"/g,'\\\"').replace(/\*/g,"\\\*").replace(/\?/g,"\\\?").replace(/&/g,"\\\&").replace(/\;/g,"\\\;").replace(/~/g,"\\\~"));
			//$j("#cfddns_get_ipv4_url").val(db_cfddns_["cfddns_get_ipv4_url"]);//获得IPv4的URL
			//$j("#cfddns_get_ipv6_cmd").val(db_cfddns_["cfddns_get_ipv6_cmd"]);//获得IPv6的命令
			//$j("#cfddns_get_ipv6_cmd").val($j("#cfddns_get_ipv6_cmd").val().replace(/\|/g,"\\\|").replace(/\$/g,"\\\$").replace(/'/g,"\\\'").replace(/"/g,'\\\"').replace(/\*/g,"\\\*").replace(/\?/g,"\\\?").replace(/&/g,"\\\&").replace(/\;/g,"\\\;").replace(/~/g,"\\\~"));
			//$j("#cfddns_get_ipv6_url").val(db_cfddns_["cfddns_get_ipv6_url"]);//获得IPv6的URL
			$j("#cfddns_crontab_interval").val(db_cfddns_["cfddns_crontab_interval"]);//Crontab计划任务检测间隔时间
			if($j("#cfddns_crontab_interval").val() == null){
				$j("#cfddns_crontab_interval").val(0);
			}
			
			//$j("#cfddns_verify_account").val(db_cfddns_["cfddns_verify_account"]);
			if(["true", "false"].indexOf($j("#cfddns_verify_account").val()) == -1){
				$j("#cfddns_verify_account").val(false);
			}
			//$j("#cfddns_zone_id").val(db_cfddns_["cfddns_zone_id"]);
			//$j("#cfddns_ipv4_record_id").val(db_cfddns_["cfddns_ipv4_record_id"]);
			//$j("#cfddns_ipv6_record_id").val(db_cfddns_["cfddns_ipv6_record_id"]);
			
			
			
			//显示日志框
			$j("#cfddns_log_button").click(function () {
				get_Log();
				$j("#vpnc_settings").fadeIn();
			});
			//刷新日志
			$j("#refresh_log").click(function () {
				get_Log();
			});
			//隐藏日志框
			$j("#close_log_win").click(function () {
				$j("#vpnc_settings").fadeOut();
			});
			$j("#logtxt").change(function () {
				$j("#logtxt").scrollTop = $j("#logtxt").scrollHeight;
			})
			//刷新状态
			$j("#cfddns_status_button").click(function () {
				get_satus_try_times=0;
				get_satus();
			});

			//获取状态
//			get_satus();
			get_satus_log();
		}

		function buildswitch() {
			$j("#switch_main").click(
				function () {
					if (document.getElementById('switch_main').checked) {
						document.form.cfddns_enable.value = true;
						//$j("#cfddns_table_config").show();
					} else {
						document.form.cfddns_enable.value = false;
						//$j("#cfddns_table_config").hide();
					}
				});
			$j("#switch_cfddns_auto_create_zone").click(
				function () {
					if (document.getElementById('switch_cfddns_auto_create_zone').checked) {
						document.form.cfddns_auto_create_zone.value = true;
						$j("#tr_cfddns_auto_create_zone_jump_start").show();
						$j("#tr_cfddns_auto_create_zone_type").show();
					} else {
						document.form.cfddns_auto_create_zone.value = false;
						$j("#tr_cfddns_auto_create_zone_jump_start").hide();
						$j("#tr_cfddns_auto_create_zone_type").hide();
					}
				});
			$j("#switch_cfddns_auto_create_zone_jump_start").click(
				function () {
					if (document.getElementById('switch_cfddns_auto_create_zone_jump_start').checked) {
						document.form.cfddns_auto_create_zone_jump_start.value = true;
					} else {
						document.form.cfddns_auto_create_zone_jump_start.value = false;
					}
				});
			$j("#switch_cfddns_detailed_config").click(
				function () {
					if (document.getElementById('switch_cfddns_detailed_config').checked) {
						document.form.cfddns_detailed_config.value = true;
						$j("#tr_cfddns_ttl").hide();
						$j("#tr_cfddns_proxied").hide();
						$j("#tr_cfddns_auto_create_record").hide();
						$j("#tr_cfddns_auto_delete_redundant_records").hide();
						$j("#tr_cfddns_ipv4_ttl").show();
						$j("#tr_cfddns_ipv4_proxied").show();
						$j("#tr_cfddns_ipv4_auto_create_record").show();
						$j("#tr_cfddns_ipv4_auto_delete_redundant_records").show();
						$j("#tr_cfddns_ipv6_ttl").show();
						$j("#tr_cfddns_ipv6_proxied").show();
						$j("#tr_cfddns_ipv6_auto_create_record").show();
						$j("#tr_cfddns_ipv6_auto_delete_redundant_records").show();
					} else {
						document.form.cfddns_detailed_config.value = false;
						$j("#tr_cfddns_ttl").show();
						$j("#tr_cfddns_proxied").show();
						$j("#tr_cfddns_auto_create_record").show();
						$j("#tr_cfddns_auto_delete_redundant_records").show();
						$j("#tr_cfddns_ipv4_ttl").hide();
						$j("#tr_cfddns_ipv4_proxied").hide();
						$j("#tr_cfddns_ipv4_auto_create_record").hide();
						$j("#tr_cfddns_ipv4_auto_delete_redundant_records").hide();
						$j("#tr_cfddns_ipv6_ttl").hide();
						$j("#tr_cfddns_ipv6_proxied").hide();
						$j("#tr_cfddns_ipv6_auto_create_record").hide();
						$j("#tr_cfddns_ipv6_auto_delete_redundant_records").hide();
					}
				});
			$j("#switch_cfddns_proxied").click(
				function () {
					if (document.getElementById('switch_cfddns_proxied').checked) {
						document.form.cfddns_proxied.value = true;
					} else {
						document.form.cfddns_proxied.value = false;
					}
				});
			$j("#switch_cfddns_auto_create_record").click(
				function () {
					if (document.getElementById('switch_cfddns_auto_create_record').checked) {
						document.form.cfddns_auto_create_record.value = true;
					} else {
						document.form.cfddns_auto_create_record.value = false;
					}
				});
			$j("#switch_cfddns_auto_delete_redundant_records").click(
				function () {
					if (document.getElementById('switch_cfddns_auto_delete_redundant_records').checked) {
						document.form.cfddns_auto_delete_redundant_records.value = true;
					} else {
						document.form.cfddns_auto_delete_redundant_records.value = false;
					}
				});
			$j("#switch_cfddns_ipv4_proxied").click(
				function () {
					if (document.getElementById('switch_cfddns_ipv4_proxied').checked) {
						document.form.cfddns_ipv4_proxied.value = true;
					} else {
						document.form.cfddns_ipv4_proxied.value = false;
					}
				});
			$j("#switch_cfddns_ipv4_auto_create_record").click(
				function () {
					if (document.getElementById('switch_cfddns_ipv4_auto_create_record').checked) {
						document.form.cfddns_ipv4_auto_create_record.value = true;
					} else {
						document.form.cfddns_ipv4_auto_create_record.value = false;
					}
				});
			$j("#switch_cfddns_ipv4_auto_delete_redundant_records").click(
				function () {
					if (document.getElementById('switch_cfddns_ipv4_auto_delete_redundant_records').checked) {
						document.form.cfddns_ipv4_auto_delete_redundant_records.value = true;
					} else {
						document.form.cfddns_ipv4_auto_delete_redundant_records.value = false;
					}
				});
			$j("#switch_cfddns_ipv6_proxied").click(
				function () {
					if (document.getElementById('switch_cfddns_ipv6_proxied').checked) {
						document.form.cfddns_ipv6_proxied.value = true;
					} else {
						document.form.cfddns_ipv6_proxied.value = false;
					}
				});
			$j("#switch_cfddns_ipv6_auto_create_record").click(
				function () {
					if (document.getElementById('switch_cfddns_ipv6_auto_create_record').checked) {
						document.form.cfddns_ipv6_auto_create_record.value = true;
					} else {
						document.form.cfddns_ipv6_auto_create_record.value = false;
					}
				});
			$j("#switch_cfddns_ipv6_auto_delete_redundant_records").click(
				function () {
					if (document.getElementById('switch_cfddns_ipv6_auto_delete_redundant_records').checked) {
						document.form.cfddns_ipv6_auto_delete_redundant_records.value = true;
					} else {
						document.form.cfddns_ipv6_auto_delete_redundant_records.value = false;
					}
				});
		}

		function onSubmitCtrl(o, s) {
			if (validatorDone()) {
				if(db_cfddns_["cfddns_user_email"] != $j("#cfddns_user_email").val()){
					$j("#cfddns_verify_account").val("false");
					$j("#cfddns_zone_id").val("");
					$j("#cfddns_cf_ipv4_content").val("");
					$j("#cfddns_cf_ipv4_ttl").val("");
					$j("#cfddns_cf_ipv4_proxied").val("");
					$j("#cfddns_cf_ipv6_content").val("");
					$j("#cfddns_cf_ipv6_ttl").val("");
					$j("#cfddns_cf_ipv6_proxied").val("");
					$j("#cfddns_ipv4_record_id").val("");
					$j("#cfddns_ipv6_record_id").val("");
				}
				else if(db_cfddns_["cfddns_root_domain_name"] != $j("#cfddns_root_domain_name").val()){
					$j("#cfddns_zone_id").val("");
					$j("#cfddns_cf_ipv4_content").val("");
					$j("#cfddns_cf_ipv4_ttl").val("");
					$j("#cfddns_cf_ipv4_proxied").val("");
					$j("#cfddns_cf_ipv6_content").val("");
					$j("#cfddns_cf_ipv6_ttl").val("");
					$j("#cfddns_cf_ipv6_proxied").val("");
					$j("#cfddns_ipv4_record_id").val("");
					$j("#cfddns_ipv6_record_id").val("");
				}
				else if(db_cfddns_["cfddns_subdomain_name_prefix"] != $j("#cfddns_subdomain_name_prefix").val()){
					$j("#cfddns_cf_ipv4_content").val("");
					$j("#cfddns_cf_ipv4_ttl").val("");
					$j("#cfddns_cf_ipv4_proxied").val("");
					$j("#cfddns_cf_ipv6_content").val("");
					$j("#cfddns_cf_ipv6_ttl").val("");
					$j("#cfddns_cf_ipv6_proxied").val("");
					$j("#cfddns_ipv4_record_id").val("");
					$j("#cfddns_ipv6_record_id").val("");
				}
//				else{
//					$j("#cfddns_cf_ipv4_content").val("ipv4_content");
//					$j("#cfddns_cf_ipv4_ttl").val("ipv4_ttl");
//					$j("#cfddns_cf_ipv4_proxied").val("ipv4_proxied");
//					$j("#cfddns_cf_ipv6_content").val("ipv6_content");
//					$j("#cfddns_cf_ipv6_ttl").val("ipv6_ttl");
//					$j("#cfddns_cf_ipv6_proxied").val("ipv6_proxied");
//					$j("#cfddns_ipv4_record_id").val("ipv4_record_id");
//					$j("#cfddns_ipv6_record_id").val("ipv6_record_id");
////				alert($j("#cfddns_cf_ipv4_content").val()+"\n"+
////					$j("#cfddns_cf_ipv4_ttl").val()+"\n"+
////					$j("#cfddns_cf_ipv4_proxied").val()+"\n"+
////					$j("#cfddns_cf_ipv6_content").val()+"\n"+
////					$j("#cfddns_cf_ipv6_ttl").val()+"\n"+
////					$j("#cfddns_cf_ipv6_proxied").val()+"\n"+
////					$j("#cfddns_ipv4_record_id").val()+"\n"+
////					$j("#cfddns_ipv6_record_id").val());
//				}
				
				
				
				let arr = ["1", "120", "300", "600", "900", "1800", "3600", "7200", "18000", "43200", "86400"];
				if($j("#cfddns_detailed_config").val() == "false"){
					//alert(arr.indexOf($j("#cfddns_ttl").val()));
					if(arr.indexOf($j("#cfddns_ttl").val()) == -1)
						$j("#cfddns_ttl").val(1);
						
					$j("#cfddns_ipv4_ttl").val($j("#cfddns_ttl").val());
					$j("#cfddns_ipv4_proxied").val($j("#cfddns_proxied").val());
					$j("#cfddns_ipv4_auto_create_record").val($j("#cfddns_auto_create_record").val());
					$j("#cfddns_ipv4_auto_delete_redundant_records").val($j("#cfddns_auto_delete_redundant_records").val());
					$j("#cfddns_ipv6_ttl").val($j("#cfddns_ttl").val());
					$j("#cfddns_ipv6_proxied").val($j("#cfddns_proxied").val());
					$j("#cfddns_ipv6_auto_create_record").val($j("#cfddns_auto_create_record").val());
					$j("#cfddns_ipv6_auto_delete_redundant_records").val($j("#cfddns_auto_delete_redundant_records").val());
				}
				else{
					if(arr.indexOf($j("#cfddns_ipv4_ttl").val()) == -1)
						$j("#cfddns_ipv4_ttl").val(1);
					if(arr.indexOf($j("#cfddns_ipv6_ttl").val()) == -1)
						$j("#cfddns_ipv6_ttl").val(1);
				}
				
				
				$j("#cfddns_get_ipv4_cmd").val($j("#cfddns_get_ipv4_cmd").val().replace(/\\\|/g,"|").replace(/\\\$/g,"$").replace(/\\'/g,"'").replace(/\\"/g,'"').replace(/\\\*/g,"*").replace(/\\\?/g,"?").replace(/\\&/g,"&").replace(/\\\;/g,";").replace(/\\~/g,"~"));
				$j("#cfddns_get_ipv4_cmd").val($j("#cfddns_get_ipv4_cmd").val().replace(/\|/g,"\\\|").replace(/\$/g,"\\\$").replace(/'/g,"\\\'").replace(/"/g,'\\\"').replace(/\*/g,"\\\*").replace(/\?/g,"\\\?").replace(/&/g,"\\\&").replace(/\;/g,"\\\;").replace(/~/g,"\\\~"));
				$j("#cfddns_get_ipv6_cmd").val($j("#cfddns_get_ipv6_cmd").val().replace(/\\\|/g,"|").replace(/\\\$/g,"$").replace(/\\'/g,"'").replace(/\\"/g,'"').replace(/\\\*/g,"*").replace(/\\\?/g,"?").replace(/\\&/g,"&").replace(/\\\;/g,";").replace(/\\~/g,"~"));
				$j("#cfddns_get_ipv6_cmd").val($j("#cfddns_get_ipv6_cmd").val().replace(/\|/g,"\\\|").replace(/\$/g,"\\\$").replace(/'/g,"\\\'").replace(/"/g,'\\\"').replace(/\*/g,"\\\*").replace(/\?/g,"\\\?").replace(/&/g,"\\\&").replace(/\;/g,"\\\;").replace(/~/g,"\\\~"));
				//alert($j("#cfddns_get_ipv4_cmd").val()+"\n"+$j("#cfddns_get_ipv6_cmd").val());
				
				if($j("#cfddns_get_ipv4_url").val() == ""){
					$j("#cfddns_get_ipv4_url").val("https://ipv4.icanhazip.com")
				}
				if($j("#cfddns_get_ipv6_url").val() == ""){
					$j("#cfddns_get_ipv6_url").val("https://ipv6.icanhazip.com")
				}
				
				document.form.action_mode.value = s;
				showLoading(3);
				document.form.submit();
				
				setTimeout(function () { $j("#vpnc_settings").fadeIn(); get_Log(true); }, 3000);
				//setTimeout(function () { $j("#vpnc_settings").fadeIn(); }, 1000);
			}
		}
		

		function reload_Soft_Center() {
			location.href = "/Main_Soft_center.asp";
		}
		//数据简单校验
		function validatorDone() {
			if (!isEmail($j("#cfddns_user_email").val())) {
				alert("邮箱格式错误");
				$j("#cfddns_user_email").focus();
				return false;
			}
			if ($j("#cfddns_ttl").val() && !isNumber($j("#cfddns_ttl").val())) {
				alert("ttl必须是数字");
				$j("#cfddns_ttl").focus();
				return false;
			}
			if (["ipv4", "ipv6", "both"].indexOf($j("#cfddns_update_object").val()) == -1){
				alert("更新对象错误");
				$j("#cfddns_update_object").focus();
				return false;
			}
			return true;
		}
		//数字校验
		function isNumber(value) {
			var reg = /^(-)?\d+(\.\d+)?$/;
			if (value.match(reg) == null || value == "") {
				return false
			} else {
				return true
			}
		}
		//邮箱校验
		function isEmail(value) {
			var reg = /^[a-zA-Z0-9_.-]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.[a-zA-Z0-9]{2,6}$/;
			if (value.match(reg) == null || value == "") {
				return false
			} else {
				return true
			}
		}
		//获取状态
		function get_satus() {
			if (document.getElementById('switch_main').checked){
				$j.ajax({
					url: 'apply.cgi?current_page=Module_cfddns.asp&next_page=Module_cfddns.asp&group_id=&modified=0&action_mode=+Refresh+&action_script=&action_wait=&first_time=&preferred_lang=CN&SystemCmd=cfddns_status.sh&firmver=3.0.0.4',
					dataType: 'html',
					error: function (xhr) {
						alert("error");
					},
					success: function (response) {
						$j("#cfddns_status").empty();
						$j("#cfddns_status").append("<span>执行脚本中.....</span>");
						setTimeout(function () { get_satus_log(); }, 5000);
					}
				});
			}
			else{
				$j("#cfddns_status").empty();
				$j("#cfddns_status").append("未运行");
			}
		}
		//加载状态
		function get_satus_log() {
			$j("#cfddns_status").empty();
			if ( get_satus_try_times == 0 ){
				$j("#cfddns_status").append("<span>获取状态中.....</span>");
			}
			else{
				$j("#cfddns_status").append("<span>获取状态中.....尝试 "+get_satus_try_times+" </span>");
			}
			
			$j.get("/res/cfddns_status.htm", function (data, status) {
				data=data.trim();
				//alert("data\n'"+data.trim()+"'\nstatus\n'"+status+"'");
				if (status == "error") {
					$j("#cfddns_status").append("<span style='color:red;'>获取状态错误!!!!!</span>");
					console.log(status);
					return;
				}
				else if ( data == "" ){
					get_satus();
					return;
				}
				else if ( data == "running" ){
					get_satus_try_times++;
					setTimeout(function () { get_satus_log(); }, 1000);
					return;
				}
				var obj = isJsonString(data);
				if (!obj) {
					//alert("data\n'"+data+"'");
					get_satus_try_times=0;
					$j("#cfddns_status").empty();
					$j("#cfddns_status").append("<p style='color:red;'>获取状态结果失败！</p>");
					return;
				}
				$j("#cfddns_status").empty();
				$j("#cfddns_status").append("<span>检测时间:" + obj.date + "</span>");
				if(obj.error != "none"){
					$j("#cfddns_status").append("<p style='color:red;'>" + obj.error + "</p>");
				}else{
					if(obj.local_ipv4 != "未启用"){
						if(obj.local_ipv4 == "获取失败" || obj.cf_ipv4 == "获取失败"){
							$j("#cfddns_status").append("<p style='color:red;'>本地IPv4:" + obj.local_ipv4 + "</p>");
							$j("#cfddns_status").append("<p style='color:red;'>cf IPv4:" + obj.cf_ipv4 + "</p>");
						}
						else if(obj.local_ipv4 != "" && obj.local_ipv4 == obj.cf_ipv4){
							$j("#cfddns_status").append("<p style='color:green;'>本地IPv4:" + obj.local_ipv4 + "</p>");
							$j("#cfddns_status").append("<p style='color:green;'>cf IPv4:" + obj.cf_ipv4 + "</p>");
						}else{
							$j("#cfddns_status").append("<p style='color:yellow;'>本地IPv4:" + obj.local_ipv4 + "</p>");
							$j("#cfddns_status").append("<p style='color:yellow;'>cf IPv4:" + obj.cf_ipv4 + "</p>");
						}
					}
					if(obj.local_ipv6 != "未启用"){
						if(obj.local_ipv6 == "获取失败" || obj.cf_ipv6 == "获取失败"){
							$j("#cfddns_status").append("<p style='color:red;'>本地IPv6:" + obj.local_ipv6 + "</p>");
							$j("#cfddns_status").append("<p style='color:red;'>cf IPv6:" + obj.cf_ipv6 + "</p>");
						}
						else if(obj.local_ipv6 != "" && obj.local_ipv6 == obj.cf_ipv6){
							$j("#cfddns_status").append("<p style='color:green;'>本地IPv6:" + obj.local_ipv6 + "</p>");
							$j("#cfddns_status").append("<p style='color:green;'>cf IPv6:" + obj.cf_ipv6 + "</p>");
						}else{
							$j("#cfddns_status").append("<p style='color:yellow;'>本地IPv6:" + obj.local_ipv6 + "</p>");
							$j("#cfddns_status").append("<p style='color:yellow;'>cf IPv6:" + obj.cf_ipv6 + "</p>");
						}
					}
					
				}
			});
		}

		function isJsonString(str) {
			if (typeof str == 'string') {
				try {
					var obj = JSON.parse(str);
					if (typeof obj == 'object' && obj) {
						return obj;
					} else {
						return null;
					}

				} catch (e) {
					return null;
				}
			}
		}
		//加载日志内容
		function get_Log(continuous) {
			//$j("#logtxt").empty();
			$j("#logtxt").load("/res/cfddns_log.htm", function (paresponseTxt, statusTxt, xhrrams) {
				var scrollTop = $j("#logtxt")[0].scrollHeight;
				$j("#logtxt").scrollTop(scrollTop);
				if (statusTxt == "error") {
					alert("Error: " + xhr.status + ": " + xhr.statusText);
				} 
				else if (continuous) {
					var logs = paresponseTxt.split("\n");
					let isover = false;
					$j.each(logs, function () {
						var logrow = this;
						if (logrow.indexOf("运行完毕!!!") != -1) {
							//alert("log end\n"+logrow);
							console.log(logrow);
							isover = true;
							setTimeout(function () { get_satus_log(); }, 1000);
							$j("#logtxt").append("------------------------------运行完成,可以关闭本窗口了----------------------------");
							return false;
						}
					});
					if (!isover && !$j("#vpnc_settings").is(':hidden')) {
						setTimeout(function () { get_Log(true); }, 1000);
					}
				}
			})
		}

		function menu_hook(title, tab) {
			tabtitle[tabtitle.length - 1] = new Array("", "cfddns");
			tablink[tablink.length - 1] = new Array("", "Module_cfddns.asp");
		}
	</script>
	<style>
		.contentM_qis {
			position: absolute;
			-webkit-border-radius: 5px;
			-moz-border-radius: 5px;
			border-radius: 10px;
			z-index: 10;
			background-color: #2B373B;
			margin-left: -215px;
			top: 240px;
			width: 980px;
			height: auto;
			box-shadow: 3px 3px 10px #000;
			background: rgba(0, 0, 0, 0.85);
			display: none;
		}
	</style>
</head>

<body onload="init();">
	<div id="TopBanner"></div>
	<div id="Loading" class="popup_bg"></div>
	<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
	<form method="POST" name="form" action="/applydb.cgi?p=cfddns_" target="hidden_frame">
		<input type="hidden" name="current_page" value="Module_cfddns.asp" />
		<input type="hidden" name="next_page" value="Module_cfddns.asp" />
		<input type="hidden" name="group_id" value="" />
		<input type="hidden" name="modified" value="0" />
		<input type="hidden" name="action_mode" value="" />
		<input type="hidden" name="action_script" value="" />
		<input type="hidden" name="action_wait" value="5" />
		<input type="hidden" name="first_time" value="" />
		<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get(" preferred_lang "); %>"/>
		<input type="hidden" name="SystemCmd" onkeydown="onSubmitCtrl(this, ' Refresh ')" value="cfddns_run.sh" />
		<input type="hidden" name="firmver" value="<% nvram_get(" firmver "); %>"/>
		<input type="hidden" id="cfddns_enable" name="cfddns_enable" value='<% dbus_get_def("cfddns_enable", false); %>' />
		<input type="hidden" id="cfddns_verify_account" name="cfddns_verify_account" value='<% dbus_get_def("cfddns_verify_account", false); %>' />
		<input type="hidden" id="cfddns_zone_id" name="cfddns_zone_id" value='<% dbus_get_def("cfddns_zone_id", ""); %>' />
		<input type="hidden" id="cfddns_auto_create_zone" name="cfddns_auto_create_zone" value='<% dbus_get_def("cfddns_auto_create_zone", true); %>' />
		<input type="hidden" id="cfddns_auto_create_zone_jump_start" name="cfddns_auto_create_zone_jump_start" value='<% dbus_get_def("cfddns_auto_create_zone_jump_start", false); %>' />
		<input type="hidden" id="cfddns_detailed_config" name="cfddns_detailed_config" value='<% dbus_get_def("cfddns_detailed_config", false); %>' />
		<input type="hidden" id="cfddns_proxied" name="cfddns_proxied" value='<% dbus_get_def("cfddns_proxied", false); %>' />
		<input type="hidden" id="cfddns_auto_create_record" name="cfddns_auto_create_record" value='<% dbus_get_def("cfddns_auto_create_record", true); %>' />
		<input type="hidden" id="cfddns_auto_delete_redundant_records" name="cfddns_auto_delete_redundant_records" value='<% dbus_get_def("cfddns_auto_delete_redundant_records", false); %>' />
		<input type="hidden" id="cfddns_ipv4_proxied" name="cfddns_ipv4_proxied" value='<% dbus_get_def("cfddns_ipv4_proxied", false); %>' />
		<input type="hidden" id="cfddns_ipv4_auto_create_record" name="cfddns_ipv4_auto_create_record" value='<% dbus_get_def("cfddns_ipv4_auto_create_record", true); %>' />
		<input type="hidden" id="cfddns_ipv4_auto_delete_redundant_records" name="cfddns_ipv4_auto_delete_redundant_records" value='<% dbus_get_def("cfddns_ipv4_auto_delete_redundant_records", false); %>' />
		<input type="hidden" id="cfddns_ipv6_proxied" name="cfddns_ipv6_proxied" value='<% dbus_get_def("cfddns_ipv6_proxied", false); %>' />
		<input type="hidden" id="cfddns_ipv6_auto_create_record" name="cfddns_ipv6_auto_create_record" value='<% dbus_get_def("cfddns_ipv6_auto_create_record", true); %>' />
		<input type="hidden" id="cfddns_ipv6_auto_delete_redundant_records" name="cfddns_ipv6_auto_delete_redundant_records" value='<% dbus_get_def("cfddns_ipv6_auto_delete_redundant_records", false); %>' />
		<input type="hidden" id="cfddns_cf_ipv4_content" name="cfddns_cf_ipv4_content" value='<% dbus_get_def("cfddns_cf_ipv4_content", ""); %>' />
		<input type="hidden" id="cfddns_cf_ipv4_ttl" name="cfddns_cf_ipv4_ttl" value='<% dbus_get_def("cfddns_cf_ipv4_ttl", 0); %>' />
		<input type="hidden" id="cfddns_cf_ipv4_proxied" name="cfddns_cf_ipv4_proxied" value='<% dbus_get_def("cfddns_cf_ipv4_proxied", false); %>' />
		<input type="hidden" id="cfddns_cf_ipv6_content" name="cfddns_cf_ipv6_content" value='<% dbus_get_def("cfddns_cf_ipv6_content", ""); %>' />
		<input type="hidden" id="cfddns_cf_ipv6_ttl" name="cfddns_cf_ipv6_ttl" value='<% dbus_get_def("cfddns_cf_ipv6_ttl", 0); %>' />
		<input type="hidden" id="cfddns_cf_ipv6_proxied" name="cfddns_cf_ipv6_proxied" value='<% dbus_get_def("cfddns_cf_ipv6_proxied", false); %>' />
		<input type="hidden" id="cfddns_ipv4_record_id" name="cfddns_ipv4_record_id" value='<% dbus_get_def("cfddns_ipv4_record_id", ""); %>' />
		<input type="hidden" id="cfddns_ipv6_record_id" name="cfddns_ipv6_record_id" value='<% dbus_get_def("cfddns_ipv6_record_id", ""); %>' />
		
		<table class="content" align="center" cellpadding="0" cellspacing="0">
			<tr>
				<td width="17">&nbsp;</td>
				<td valign="top" width="202">
					<div id="mainMenu"></div>
					<div id="subMenu"></div>
				</td>
				<td valign="top">
					<div id="tabMenu" class="submenuBlock"></div>
					<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
						<tr>
							<td align="left" valign="top">
								<table width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
									<tr>
										<td bgcolor="#4D595D" colspan="3" valign="top">
											<div>&nbsp;</div>
											<div style="float:left;" class="formfonttitle">Cloudflare DDNS - 设置</div>
											<div style="float:right; width:15px; height:25px;margin-top:10px">
												<img id="return_btn" onclick="reload_Soft_Center();" align="right" style="cursor:pointer;position:absolute;margin-left:-30px;margin-top:-25px;"
												 title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img>
											</div>
											<div style="margin-left:5px;margin-top:10px;margin-bottom:10px">
												<img src="/images/New_ui/export/line_export.png">
											</div>
											<div class="formfontdesc" id="cmdDesc">该工具用于设置Cloudflare DDNS”。</div>
											<div class="formfontdesc" id="cmdDesc"></div>
											<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3"
											 class="FormTable" id="cfddns_table_main">
												<thead>
													<tr>
														<td colspan="2">主要选项</td>
													</tr>
												</thead>
												<tr>
													<th>启动CFDDNS</th>
													<td colspan="2">
														<div class="switch_field" style="display:table-cell;float: left;">
															<label for="switch_main">
																<input id="switch_main" class="switch" type="checkbox" style="display: none;">
																<div class="switch_container">
																	<div class="switch_bar"></div>
																	<div class="switch_circle transition_style">
																		<div></div>
																	</div>
																</div>
															</label>
														</div>
														<div style="display:table-cell;float: right;">
															<a id="cfddns_log_button" href="javascript:void(0)"><em>[<u> 运行日志 </u>]</em></a>
														</div>
														<div style="display:table-cell;float: right;">
															<i id="cfddns_version_show">当前版本：<% dbus_get_def("softcenter_module_cfddns_version", "未知"); %></i>
														</div>
													</td>
												</tr>
												<tr>
													<th>运行状态</th>
													<td colspan="2">
														<div style="display:table-cell;float: left;">
															<i id="cfddns_status">未运行</i>
														</div>
														<div style="display:table-cell;float: right;">
															<a id="cfddns_status_button" href="javascript:void(0)">
																<em>[<u> 刷新状态 </u>]</em>
															</a>
														</div>
													</td>
												</tr>
											</table>

											<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3"
											 class="FormTable" id="cfddns_table_config">
												<thead>
													<tr>
														<td colspan="2">服务配置</td>
													</tr>
												</thead>
												<tr id="tr_cfddns_user_email">
													<th width="35%">用户邮箱(User Email)</th>
													<td>
														<input type="text" maxlength="64" id="cfddns_user_email" name="cfddns_user_email" value="" style="width:50%;float:left;"
														 autocomplete="off" autocorrect="off" autocapitalize="off" />
													</td>
												</tr>
												<tr id="tr_cfddns_global_api_key">
													<th width="35%">用户全局密钥(GLOBAL API KEY)</th>
													<td>
														<input type="password" maxlength="64" id="cfddns_global_api_key" name="cfddns_global_api_key" value="" style="width:50%;float:left;"
														 autocomplete="off" autocorrect="off" autocapitalize="off" />
													</td>
												</tr>
												<tr id="tr_cfddns_domain_name">
													<th width="35%">域名(Domain Name)</th>
													<td>
														<input type="text" maxlength="64" id="cfddns_subdomain_name_prefix" name="cfddns_subdomain_name_prefix" value="" style="width:20%;float:left;"
														 autocomplete="off" autocorrect="off" autocapitalize="off" placeholder="子域名" />
														 <span style="float:left;">.</span>
														 <input type="text" maxlength="64" id="cfddns_root_domain_name" name="cfddns_root_domain_name" value="" style="width:40%;float:left;"
														 autocomplete="off" autocorrect="off" autocapitalize="off" placeholder="主域名" />
													</td>
												</tr>
												<tr id="tr_cfddns_auto_create_zone">
													<th  width="35%" title="如果未将网站添加到Cloudflare则第一次使用必须启用该项">自动创建域(Auto create zone)[?]</th>
													<td>
														<div class="switch_field" style="display:table-cell;float: left;">
															<label for="switch_cfddns_auto_create_zone">
																<input id="switch_cfddns_auto_create_zone" class="switch" type="checkbox" style="display: none;">
																<div class="switch_container">
																	<div class="switch_bar"></div>
																	<div class="switch_circle transition_style">
																		<div></div>
																	</div>
																</div>
															</label>
														</div>
													</td>
												</tr>
												<tr id="tr_cfddns_auto_create_zone_jump_start">
													<th  width="35%">自动尝试获取现有DNS记录(Jump start)</th>
													<td>
														<div class="switch_field" style="display:table-cell;float: left;">
															<label for="switch_cfddns_auto_create_zone_jump_start">
																<input id="switch_cfddns_auto_create_zone_jump_start" class="switch" type="checkbox" style="display: none;">
																<div class="switch_container">
																	<div class="switch_bar"></div>
																	<div class="switch_circle transition_style">
																		<div></div>
																	</div>
																</div>
															</label>
														</div>
													</td>
												</tr>
												<tr id="tr_cfddns_auto_create_zone_type">
													<th width="35%" title="完全或是部分由Cloudflare管理">托管类型(Zone type)[?]</th>
													<td>
														<div style="float:left; width:165px; height:25px">
															<select id="cfddns_auto_create_zone_type" name="cfddns_auto_create_zone_type" style="width:164px;margin:0px 0px 0px 2px;" class="input_option">
																<option value="full">完全</option>
																<option value="partial">部分</option>
															</select>
														</div>
													</td>
												</tr>
												
												
												
												
												
												<tr id="tr_cfddns_update_object">
													<th width="35%" title="只更新IPv4或只更新IPv6(请先确认路由是否能获得IPv6地址,并且能上网)或两者都更新">更新对象(Update object)[?]</th>
													<td>
														<div style="float:left; width:165px; height:25px">
															<select id="cfddns_update_object" name="cfddns_update_object" style="width:164px;margin:0px 0px 0px 2px;" class="input_option">
																<option value="ipv4" selected>IPv4</option>
																<option value="ipv6">IPv6</option>
																<option value="both">Both</option>
															</select>
														</div>
													</td>
												</tr>
												
												<tr id="tr_cfddns_detailed_config">
													<th width="35%" title="分别配置IPv4和IPv6">详细配置(Detailed configuration)[?]</th>
													<td>
														<div class="switch_field" style="display:table-cell;float: left;">
															<label for="switch_cfddns_detailed_config">
																<input id="switch_cfddns_detailed_config" class="switch" type="checkbox" style="display: none;">
																<div class="switch_container">
																	<div class="switch_bar"></div>
																	<div class="switch_circle transition_style">
																		<div></div>
																	</div>
																</div>
															</label>
														</div>
													</td>
												</tr>
												
												
												<tr id="tr_cfddns_ttl">
													<th width="35%" title="设置解析TTL，免费版的范围是[1,120,300,600,900,1800,3600,7200,18000,43200,86400],默认为1">生存时间(TTL)[?]</th>
													<td>
														<input type="text" maxlength="64" id="cfddns_ttl" name="cfddns_ttl" value="" style="width:10%;float:left;"
														 autocomplete="off" autocorrect="off" autocapitalize="off" />
													</td>
												</tr>
												<tr id="tr_cfddns_proxied">
													<th width="35%" title="开启后所有流量经Cloudflare再到路由器">Cloudflare代理(proxied)[?]</th>
													<td>
														<div class="switch_field" style="display:table-cell;float: left;">
															<label for="switch_cfddns_proxied">
																<input id="switch_cfddns_proxied" class="switch" type="checkbox" style="display: none;">
																<div class="switch_container">
																	<div class="switch_bar"></div>
																	<div class="switch_circle transition_style">
																		<div></div>
																	</div>
																</div>
															</label>
														</div>
													</td>
												</tr>
												<tr id="tr_cfddns_auto_create_record">
													<th width="35%" title="如果未创建IPv4/IPv6(A/AAAA)记录则第一次使用必须启用该项">自动创建记录(Auto create record)[?]</th>
													<td>
														<div class="switch_field" style="display:table-cell;float: left;">
															<label for="switch_cfddns_auto_create_record">
																<input id="switch_cfddns_auto_create_record" class="switch" type="checkbox" style="display: none;">
																<div class="switch_container">
																	<div class="switch_bar"></div>
																	<div class="switch_circle transition_style">
																		<div></div>
																	</div>
																</div>
															</label>
														</div>
													</td>
												</tr>
												<tr id="tr_cfddns_auto_delete_redundant_records">
													<th width="35%" title="存在多条同类型记录时，使用CF返回的第一条，删除其它的">自动删除冗余记录(Auto delete redundant records)[?]</th>
													<td>
														<div class="switch_field" style="display:table-cell;float: left;">
															<label for="switch_cfddns_auto_delete_redundant_records">
																<input id="switch_cfddns_auto_delete_redundant_records" class="switch" type="checkbox" style="display: none;">
																<div class="switch_container">
																	<div class="switch_bar"></div>
																	<div class="switch_circle transition_style">
																		<div></div>
																	</div>
																</div>
															</label>
														</div>
													</td>
												</tr>
												
												<tr id="tr_cfddns_ipv4_ttl">
													<th width="35%" title="设置解析TTL，免费版的范围是[1,120,300,600,900,1800,3600,7200,18000,43200,86400],默认为1">IPv4 生存时间(TTL)[?]</th>
													<td>
														<input type="text" maxlength="64" id="cfddns_ipv4_ttl" name="cfddns_ipv4_ttl" value="" style="width:10%;float:left;"
														 autocomplete="off" autocorrect="off" autocapitalize="off" />
													</td>
												</tr>
												<tr id="tr_cfddns_ipv4_proxied">
													<th width="35%" title="开启后所有IPv4流量经Cloudflare再到路由器">IPv4 Cloudflare代理(proxied)[?]</th>
													<td>
														<div class="switch_field" style="display:table-cell;float: left;">
															<label for="switch_cfddns_ipv4_proxied">
																<input id="switch_cfddns_ipv4_proxied" class="switch" type="checkbox" style="display: none;">
																<div class="switch_container">
																	<div class="switch_bar"></div>
																	<div class="switch_circle transition_style">
																		<div></div>
																	</div>
																</div>
															</label>
														</div>
													</td>
												</tr>
												<tr id="tr_cfddns_ipv4_auto_create_record">
													<th  width="35%" title="如果未创建IPv4(A)记录则第一次使用必须启用该项">自动创建IPv4记录(Auto create IPv4 record)[?]</th>
													<td>
														<div class="switch_field" style="display:table-cell;float: left;">
															<label for="switch_cfddns_ipv4_auto_create_record">
																<input id="switch_cfddns_ipv4_auto_create_record" class="switch" type="checkbox" style="display: none;">
																<div class="switch_container">
																	<div class="switch_bar"></div>
																	<div class="switch_circle transition_style">
																		<div></div>
																	</div>
																</div>
															</label>
														</div>
													</td>
												</tr>
												<tr id="tr_cfddns_ipv4_auto_delete_redundant_records">
													<th width="35%" title="存在多条同类型IPv4(A)记录时，使用CF返回的第一条，删除其它的">自动删除冗余IPv4记录(Auto delete redundant IPv4 records)[?]</th>
													<td>
														<div class="switch_field" style="display:table-cell;float: left;">
															<label for="switch_cfddns_ipv4_auto_delete_redundant_records">
																<input id="switch_cfddns_ipv4_auto_delete_redundant_records" class="switch" type="checkbox" style="display: none;">
																<div class="switch_container">
																	<div class="switch_bar"></div>
																	<div class="switch_circle transition_style">
																		<div></div>
																	</div>
																</div>
															</label>
														</div>
													</td>
												</tr>
												<tr id="tr_cfddns_ipv6_ttl">
													<th width="35%" title="设置解析TTL，免费版的范围是[1,120,300,600,900,1800,3600,7200,18000,43200,86400],默认为1">IPv6 生存时间(TTL)[?]</th>
													<td>
														<input type="text" maxlength="64" id="cfddns_ipv6_ttl" name="cfddns_ipv6_ttl" value="" style="width:10%;float:left;"
														 autocomplete="off" autocorrect="off" autocapitalize="off" />
													</td>
												</tr>
												<tr id="tr_cfddns_ipv6_proxied">
													<th width="35%" title="开启后所有IPv6流量经Cloudflare再到路由器">IPv6 Cloudflare代理(proxied)[?]</th>
													<td>
														<div class="switch_field" style="display:table-cell;float: left;">
															<label for="switch_cfddns_ipv6_proxied">
																<input id="switch_cfddns_ipv6_proxied" class="switch" type="checkbox" style="display: none;">
																<div class="switch_container">
																	<div class="switch_bar"></div>
																	<div class="switch_circle transition_style">
																		<div></div>
																	</div>
																</div>
															</label>
														</div>
													</td>
												</tr>
												<tr id="tr_cfddns_ipv6_auto_create_record">
													<th  width="35%" title="如果未创建ipv6(AAAA)记录则第一次使用必须启用该项">自动创建ipv6记录(Auto create IPv6 record)[?]</th>
													<td>
														<div class="switch_field" style="display:table-cell;float: left;">
															<label for="switch_cfddns_ipv6_auto_create_record">
																<input id="switch_cfddns_ipv6_auto_create_record" class="switch" type="checkbox" style="display: none;">
																<div class="switch_container">
																	<div class="switch_bar"></div>
																	<div class="switch_circle transition_style">
																		<div></div>
																	</div>
																</div>
															</label>
														</div>
													</td>
												</tr>
												<tr id="tr_cfddns_ipv6_auto_delete_redundant_records">
													<th width="35%" title="存在多条同类型IPv6(AAAA)记录时，使用CF返回的第一条，删除其它的">自动删除冗余IPv6记录(Auto delete redundant IPv6 records)[?]</th>
													<td>
														<div class="switch_field" style="display:table-cell;float: left;">
															<label for="switch_cfddns_ipv6_auto_delete_redundant_records">
																<input id="switch_cfddns_ipv6_auto_delete_redundant_records" class="switch" type="checkbox" style="display: none;">
																<div class="switch_container">
																	<div class="switch_bar"></div>
																	<div class="switch_circle transition_style">
																		<div></div>
																	</div>
																</div>
															</label>
														</div>
													</td>
												</tr>
												
												
												<tr id="tr_cfddns_get_ipv4_cmd">
													<th width="35%" title="可自行修改命令，以获得正确的公网IPv4。如添加 '--interface vlan2' 以指定多播情况下的端口支持,可以空着">获得IPv4的命令(Command get IPv4)[?]</th>
													<td><input type="text" maxlength="256" id="cfddns_get_ipv4_cmd" name="cfddns_get_ipv4_cmd" value="<% dbus_get_def("cfddns_get_ipv4_cmd", ""); %>" style="width:100%;float:left;" placeholder="不会就空着!!!"/></td>
												</tr>
												<tr id="tr_cfddns_get_ipv4_url">
													<th width="35%" title='可自行修改URL，以获得正确的公网IPv4。默认从"https://ipv4.icanhazip.com"处获取，不保证安全性且耗时。'>获得IPv4的URL(URL get IPv4)[?]</th>
													<td><input type="text" maxlength="256" id="cfddns_get_ipv4_url" name="cfddns_get_ipv4_url" value="<% dbus_get_def("cfddns_get_ipv4_url", "https://ipv4.icanhazip.com"); %>" style="width:100%;float:left;" placeholder="不会就空着!!!"/></td>
												</tr>
												<tr id="tr_cfddns_get_ipv6_cmd">
													<th width="35%" title="可自行修改命令，以获得正确的公网ipv6。如添加 '--interface vlan2' 以指定多播情况下的端口支持,可以空着">获得ipv6的命令(Command get IPv6)[?]</th>
													<td><input type="text" maxlength="256" id="cfddns_get_ipv6_cmd" name="cfddns_get_ipv6_cmd" value="<% dbus_get_def("cfddns_get_ipv6_cmd", ""); %>" style="width:100%;float:left;" placeholder="不会就空着!!!"/></td>
												</tr>
												<tr id="tr_cfddns_get_ipv6_url">
													<th width="35%" title='可自行修改URL，以获得正确的公网ipv6。默认从"https://ipv6.icanhazip.com"处获取，不保证安全性且耗时。'>获得ipv6的URL(URL get IPv6)[?]</th>
													<td><input type="text" maxlength="256" id="cfddns_get_ipv6_url" name="cfddns_get_ipv6_url" value="<% dbus_get_def("cfddns_get_ipv6_url", "https://ipv6.icanhazip.com"); %>" style="width:100%;float:left;" placeholder="不会就空着!!!"/></td>
												</tr>
												
												
												<tr id="tr_cfddns_crontab_interval">
													<th width="35%" title="间隔一定时间更新DNS">定时任务(Timed task)[?]</th>
													<td>
														<div style="float:left; width:165px; height:25px">
															<select id="cfddns_crontab_interval" name="cfddns_crontab_interval" style="width:164px;margin:0px 0px 0px 2px;" class="input_option">
																<option value=0>关闭</option>
																<option value=5>每5分钟</option>
																<option value=10>每10分钟</option>
																<option value=15>每15分钟</option>
																<option value=30>每30分钟</option>
																<option value=60>每1小时</option>
																<option value=120>每2小时</option>
																<option value=180>每3小时</option>
																<option value=360>每6小时</option>
																<option value=720>每12小时</option>
																<option value=1440>每1天</option>
																<option value=4320>每3天</option>
																<option value=7200>每5天</option>
																<option value=14400>每10天</option>
																<option value=21600>每15天</option>
															</select>
														</div>
													</td>
												</tr>
											</table>



											<div class="apply_gen">
												<button id="cmdBtn" class="button_gen" onclick="onSubmitCtrl(this, ' Refresh ')">提交</button>
											</div>
											<div style="margin-left:5px;margin-top:10px;margin-bottom:10px">
												<img src="/images/New_ui/export/line_export.png">
											</div>
											<div id="NoteBox">
												<h2>一些说明：</h2>
												<h3 style="color:#00ffe4;">上面的检测只代表服务器设置了IP地址,一般需要一段时间来生效.这跟服务器有关.</h3>
												<h3 style="color:#00ffe4;">开启Cloudflare代理后,域名解析的IP地址为Cloudflare的IP,所有流量需经过Cloudflare服务器在到你设置的IP地址,只适用于网页</h3>
												<h3>鉴于国内封杀80端口和443端口,Cloudflare提供了几个其他端口</h3>
												<h4 style="color:gray;">http:8080,8880,2052,2082,2086,2095</h4>
												<h4 style="color:gray;">https:2053,2083,2087,2096,8443</h4>
												<h3>脚本来自论坛!!!!</h3>
												<div style="margin-left:5px;margin-top:10px;margin-bottom:10px">
													<img src="/images/New_ui/export/line_export.png">
												</div>
												参考链接:
												<a href="https://www.cloudflare.com/" target="view_window">
													<i style="margin-right:6px">Cloudflare官网</i>
												</a>
											</div>
											<div style="margin-left:5px;margin-top:10px;margin-bottom:10px">
												<img src="/images/New_ui/export/line_export.png">
											</div>
											<div class="KoolshareBottom">
												<br/>论坛技术支持：
												<a href="http://www.koolshare.cn" target="_blank">
													<i>
														<u>www.koolshare.cn</u>
													</i>
												</a>
												<br/>后台技术支持：
												<i>Xiaobao</i>
												<br/>Shell, Web by：
												<i>fw867</i>
												<br/>
											</div>
										</td>
									</tr>
								</table>
								<!-- this is the popup area for user rules -->
								<div id="vpnc_settings" class="contentM_qis" style="box-shadow: 3px 3px 10px #000;margin-top: -65px;">
									<div style="text-align: center;font-size: 18px;color: #99FF00;padding: 10px;font-weight: bold;">Cfddns运行日志</div>
									<div id="user_tr" style="margin: 10px 10px 10px 10px;width:98%;text-align:center;">
										<textarea cols="63" rows="36" wrap="off" id="logtxt" style="width:97%;padding-left:10px;padding-right:10px;border:1px solid #222;font-family:'Courier New', Courier, mono; font-size:11px;background:#475A5F;color:#FFFFFF;outline: none;"
										 autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false">
										</textarea>
									</div>
									<div style="margin-top:5px;padding-bottom:10px;width:100%;text-align:center;">
										<input id="refresh_log" class="button_gen" type="button" value="刷新日志">
									</div>
									<div style="margin-top:5px;padding-bottom:10px;width:100%;text-align:center;">
										<input id="close_log_win" class="button_gen" type="button" value="返回主界面">
									</div>
								</div>
								<!-- end of the popouparea -->
							</td>
							<td width="10" align="center" valign="top"></td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</form>
	</td>
	<div id="footer"></div>
</body>

</html>