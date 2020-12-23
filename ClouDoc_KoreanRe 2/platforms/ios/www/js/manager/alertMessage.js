function alertMessage(message) {
	if(message.toLowerCase() == "pameter missing")
		navigator.notification.alert(
				lang_parameter_missing,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "server error")
		navigator.notification.alert(
				lang_server_error,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "status stop")
		navigator.notification.alert(
				lang_status_stop,
				null,
				'Login',
				'OK'
		);
	else if(message.toLowerCase() == "incorrect password")
		navigator.notification.alert(
				lang_login_incorrect_password,
				null,
				'Login',
				'OK'
		);
	else if(message.toLowerCase() == "password expire")
		navigator.notification.alert(
				lang_login_password_expire,
				null,
				'Login',
				'OK'
		);
	else if(message.toLowerCase() == "domain disk overflow")
		navigator.notification.alert(    
				lang_login_domain_disk_overflow,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "not exists")
		navigator.notification.alert(
				lang_not_exists,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "guest expire")
		navigator.notification.alert(
				lang_login_guest_expire,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "not allowed agent")
		navigator.notification.alert(
				lang_login_not_allowed_agent,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "exception error")
		navigator.notification.alert(
				lang_exception_error,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "ip filtered")
		navigator.notification.alert(
				lang_ip_filtered,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "server busy")
		navigator.notification.alert(
				lang_server_busy,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "user busy")
		navigator.notification.alert(
				lang_user_busy,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "access denied")
		navigator.notification.alert(
				lang_access_denied,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "invalid parameter")
		navigator.notification.alert(
				lang_invalid_parameter,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "disk overflow")
		navigator.notification.alert(
				lang_disk_overflow,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "already folder exists")
		navigator.notification.alert(
				lang_already_folder_exists,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "already file error")
		navigator.notification.alert(
				lang_already_file_error,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "guest root")
		navigator.notification.alert(
				lang_guest_root,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "sharing violation")
		navigator.notification.alert(
				lang_sharing_violation,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "guest data root")
		navigator.notification.alert(
				lang_guest_data_root,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "already file exists")
		navigator.notification.alert(
				lang_already_file_exists,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "already folder error")
		navigator.notification.alert(
				lang_already_folder_error,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "has acl folder")
		navigator.notification.alert(
				lang_has_acl_folder,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "has share folder")
		navigator.notification.alert(
				lang_has_share_folder,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "substree exists")
		navigator.notification.alert(
				lang_substree_exists,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "filename filtered")
		navigator.notification.alert(
				lang_filename_filtered,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "upload limit")
		navigator.notification.alert(
				lang_upload_limit,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "upload busy")
		navigator.notification.alert(
				lang_upload_busy,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "partial success")
		navigator.notification.alert(
				lang_partial_success,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "download busy")
		navigator.notification.alert(
				lang_download_busy,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "license expired")
		navigator.notification.alert(
				lang_license_expired,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "download limit")
		navigator.notification.alert(
				lang_download_limit,
				null,
				'Alert',
				'OK'
		);
	else if(message.toLowerCase() == "need approval")
    	navigator.notification.alert(
    			lang_login_need_approval,
				null,
				'Alert',
				'OK'
    	);
    else if(message.toLowerCase() == "not exist device")
    	navigator.notification.alert(
    			lang_login_not_exist_device,
				null,
				'Alert',
				'OK'
    	);
	else if(message.toLowerCase() == "stop device")
		navigator.notification.alert(
				lang_login_stop_device,
				null,
				'Alert',
				'OK'
		);
    else if(message.toLowerCase() == "lost device")
    	navigator.notification.alert(
    			lang_login_lost_device,
				null,
				'Alert',
				'OK'
    	);
    else if(message.toLowerCase() == "not installed officesuite")
    	navigator.notification.alert(
    			lang_alert_not_exists_Officesuite,
    			null,
    			'Explorer',
    			'OK'
    	);
    /*else if(message.toLowerCase() == "lang_confrim_wifi")
    	navigator.notification.confirm(
    			lang_confrim_wifi,
				confirmwifi,
				'Explorer',
				'No, Yes'
    	);*/
	else
		navigator.notification.alert(
				message,
				null,
				'Alert',
				'OK'
		);
}

function confirmwifi(value) {
/*	if(value == "2") {		
		SetlocalStorage("Use3GDown", "yes");
		if(flag == "download")
			download("",""); 
		else
			fileopen("","");
	}
	else
		checkwifi = false;
*/
}

