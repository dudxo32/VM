var toast_lang_logSetting = "";
var toast_lang_serInfo = "";

/***************		logSettingForm		***************/
// 로그인 설정 기본값 설정
function getLogInfo() {
	$('#settingForm').fadeOut(500);
	$('#logSettingForm').fadeIn(500);
	
	var auto = GetlocalStorage("auto");
	var secureStatus = GetlocalStorage("secureStatus");
	
	var check = document.getElementsByName('onoffswitch');
	if(auto == "true")	check[0].checked = true;
	if(secureStatus == "true")	check[1].checked = true;
}

// 자동 로그인, 보안 접속 상태 저장
function saveLogSet() {
	$('#logSettingForm').fadeOut(500);
	$('#settingForm').fadeIn(500);

	var check = document.getElementsByName('onoffswitch');
	
	// 자동로그인/보안접속 여부 저장
	SetlocalStorage("auto", check[0].checked);
	SetlocalStorage("secureStatus", check[1].checked);
	
	// 로그인 유형 저장
	var loginType = document.getElementsByName('loginType');
	if(loginType != null) {
		if(loginType[2].checked)		SetlocalStorage("setLoginType", loginType[2].value);
		else if(loginType[1].checked)	SetlocalStorage("setLoginType", loginType[1].value);
		else							SetlocalStorage("setLoginType", loginType[0].value);
	}
	
	showToast(toast_lang_logSetting);
}

/***************		serInfoForm		***************/
// 서버 설정 기본값 설정
function getSerInfo() {
	$('#settingForm').fadeOut(500);
	$('#serInfoForm').fadeIn(500);
	
	var serInfo_ip = GetlocalStorage("webserver");
	var serInfo_port = GetlocalStorage("port");
	var serInfo_securityPort = GetlocalStorage("securityPort");
	
	if(serInfo_port == null)	serInfo_port = '80';
	if(serInfo_securityPort == null)	serInfo_securityPort = '443';
	
	if(serInfo_ip != null)	$('#serInfo_ip').val(serInfo_ip);
	$('#serInfo_port').val(serInfo_port);
	$('#serInfo_securityPort').val(serInfo_securityPort);
}

// 서버 정보화면 서버 입력칸 클릭 시 focus on
function serInfo_ip_focus() {
	document.getElementById('serInfo_ip').focus();
}

//서버 정보화면 포트 입력칸 클릭 시 focus on
function serInfo_port_focus() {
	document.getElementById('serInfo_port').focus();
}

//서버 정보화면 보안접속 포트 입력칸 클릭 시 focus on
function serInfo_securityPort_focus() {
	document.getElementById('serInfo_securityPort').focus();
}

//서버 정보 저장
function saveServer() {
	$('#serInfoForm').fadeOut(500);
	$('#settingForm').fadeIn(500);

	var server = $('#serInfo_ip').val();
	var port = $('#serInfo_port').val();
	var securityPort = $('#serInfo_securityPort').val();
	
	SetlocalStorage("webserver", server);
	SetlocalStorage("port", port);
	SetlocalStorage("securityPort", securityPort);
	
	showToast(toast_lang_serInfo);
}

/***************		regDeviceForm	***************/
//디바이스 등록 기본값 설정
function getRegDevInfo() {
	$('#settingForm').fadeOut(500);
	$('#regDeviceForm').fadeIn(500);

	tmpAgent = GetlocalStorage("Platform");
	tmpDeviceID = GetlocalStorage("DeviceID");
	tmpServerIP = GetlocalStorage("webserver");
	tmpUserID = GetlocalStorage("id");
	
	if(tmpAgent == "11")		tmpAgent = "IPhone";
	else if(tmpAgent == "12")	tmpAgent = "AndroidPhone";
	else if(tmpAgent == "13")	tmpAgent = "Windows";
	else 						tmpAgent = "Tablet";
	
	tmpDeviceID1 = tmpDeviceID.substr(0, 25);
	tmpDeviceID2 = tmpDeviceID.substr(25);
	tmpDeviceID = tmpDeviceID1 + " " + tmpDeviceID2;
	
	$('#deviceInfo_id').text(tmpDeviceID);
	$('#deviceInfo_model').text(tmpAgent);
	if(tmpServerIP != null)	$('#regDevice_ip').text(tmpServerIP);
	$('#regDevice_id').val(tmpUserID);
}

// 디바이스 등록화면 아이디 입력칸 클릭 시 focus on
function regDevice_id_focus() {
	document.getElementById('regDevice_id').focus();
}

// 디바이스 등록화면 비밀번호 입력칸 클릭 시 focus on
function regDevice_passwd_focus() {
	document.getElementById('regDevice_passwd').focus();
}

//디바이스 등록
function regDevice() {
    try{
	var protocol = "http";
	var server = $('#regDevice_ip').text();
	var id = $('#regDevice_id').val();
	var password = $('#regDevice_passwd').val();
	var port = GetlocalStorage("port");
	var SSLPort = GetlocalStorage("securityPort");

	if(server == "") {
		navigator.notification.alert(regDev_alert_insert_server, function(){}, 'Login', 'OK');
		return;
	}
	if(id == "") {
		navigator.notification.alert(regDev_alert_insert_id, function(){}, 'Login', 'OK');
		return;
	}
	if(password == "") {
		navigator.notification.alert(regDev_alert_insert_password, function(){}, 'Login', 'OK');
		return;
	}

	getserverinfo(protocol, port, server);
	var tmpDeviceID = GetlocalStorage("DeviceID");
	var pushid = GetlocalStorage("PUSHID");
	var DeviceInfo = device.name + "\t" + device.platform +"\t" + tmpDeviceID + "\t" + device.version +"\t"+tmpAgent;
	var value = DeviceInfo+"\t"+id+"\t"+password+"\t"+pushid;  		  		
	SetlocalStorage("id", id);

    CryptUtil = new CryptUtil();
    CryptUtil.call(function(r) {
                    loginRetArr= new Array();
                    loginRetArr= r.split("\t");

                    tmpparaData = "DeviceName=" + loginRetArr[0] + ";DevicePlatform=" + loginRetArr[1] + ";DeviceID=" + loginRetArr[2] + ";SofewareVer=" + loginRetArr[3]+";ModelName="+loginRetArr[4]
                + ";UserID=" + loginRetArr[5] + ";Password=" + loginRetArr[6]+ ";PushRegID=" + loginRetArr[7];
                    tmpCookie = "PlusVersion=version 1.0"+ ";RegSession="+ loginRetArr[8];
                    LoginparaData = "Server="+server+"&Port="+port+"&Url="+"/webapp/device_reg_request.jsp"+"&CookieData="+tmpCookie+"&ParamData="+tmpparaData;

                    useProxy = GetlocalStorage("useProxy");

                    if(useProxy == "true"){
                    us = new ProxyConnect();
                    us.proxyconn(successReg, function(){alert('fail');}, protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", LoginparaData);
                    } else {
                        LoginRetVal = AjaxRequest(protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", LoginparaData);
                        var checkretvalArr = new Array();
                        checkretvalArr= LoginRetVal.split("\r\n");
                        if("version 1.0" == checkretvalArr[0].toLowerCase()) {
                            if("success" == checkretvalArr[1].toLowerCase()) {
                            navigator.notification.alert(regDev_alert_success, function(){},'Login','OK');
                            document.getElementById('backFromRegDeviceForm').click();
                            }
                            else if(checkretvalArr[1] == "Need Approval")	navigator.notification.alert(regDev_alert_needs_approval, function(){}, 'Login', 'OK');
                            else if(checkretvalArr[1] == "Already Exist")	navigator.notification.alert(regDev_alert_already_exist, function(){}, 'Login', 'OK');
                            else if(checkretvalArr[1] == "Not Exist User")	navigator.notification.alert(regDev_alert_not_exist_user, function(){}, 'Login', 'OK');
                            else if(checkretvalArr[1] == "Exceeds Device Number")	navigator.notification.alert(regDev_alert_exceeds_number, function(){}, 'Login', 'OK');
                            else if(checkretvalArr[1] == "Incorrect Password")	navigator.notification.alert(regDev_alert_wrong_user_iofo, function(){}, 'Login', 'OK');
                            else if(checkretvalArr[1] == "Can Not Use")	navigator.notification.alert("사용할수없소", function(){}, 'Login', 'OK');
                            else
                                navigator.notification.alert(LoginRetVal, null, 'Login', 'OK');
                        }
                   }
            }, function(error){navigator.notification.alert("Device regist ERR: " + error, function(){}, 'Login', 'OK');}, value, GetlocalStorage("SiteID"));
    }catch(e){
        alert('err = ' + e);
    }
}

function successReg(LoginRetVal){
    var checkretvalArr = new Array();
    checkretvalArr= LoginRetVal.split("\r\n");
    if("version 1.0" == checkretvalArr[0].toLowerCase()) {
        if("success" == checkretvalArr[1].toLowerCase()) {
            navigator.notification.alert(regDev_alert_success, function(){},'Login','OK');
            document.getElementById('backFromRegDeviceForm').click();
        }
        else if(checkretvalArr[1] == "Need Approval")	navigator.notification.alert(regDev_alert_needs_approval, function(){}, 'Login', 'OK');
        else if(checkretvalArr[1] == "Already Exist")	navigator.notification.alert(regDev_alert_already_exist, function(){}, 'Login', 'OK');
        else if(checkretvalArr[1] == "Not Exist User")	navigator.notification.alert(regDev_alert_not_exist_user, function(){}, 'Login', 'OK');
        else if(checkretvalArr[1] == "Exceeds Device Number")	navigator.notification.alert(regDev_alert_exceeds_number, function(){}, 'Login', 'OK');
        else if(checkretvalArr[1] == "Incorrect Password")	navigator.notification.alert(regDev_alert_wrong_user_iofo, function(){}, 'Login', 'OK');
        else if(checkretvalArr[1] == "Can Not Use")	navigator.notification.alert("사용할수없소", function(){}, 'Login', 'OK');
    }
}

function regDeviceCancel() {
	$('#regDeviceForm').fadeOut(500);
	$('#settingForm').fadeIn(500);
}

/***************		extConfoForm	***************/
//외부접속 정보 불러오기
function getExtConfo() {
	$('#settingForm').fadeOut(500);
	$('#extConfoForm').fadeIn(500);
    
    ip = GetlocalStorage("ip");
    port = GetlocalStorage("proxyPort");
    useProxy = GetlocalStorage("useProxy");
	
    $('#extConfo_ip').val(ip);
    $('#extConfo_port').val(port);
    
    var useProxy = document.getElementsByName('onoffswitch');
    if(retValArray[2] == "true")	useProxy[2].checked = true;
    else							useProxy[2].checked = false;
    
//    Proxy.load(setExtConfo, function(error){navigator.notification.alert("Get external connection information ERR: " + error, function(){}, 'Login', 'OK');});
}

/* 불러온 외부접속 정보 삽입
 * getExtConfo() -> setExtConfo()
 */
function setExtConfo(retVal) {
	var retValArray = retVal.split("\t");
	$('#extConfo_ip').val(retValArray[0]);
	$('#extConfo_port').val(retValArray[1]);

	var useProxy = document.getElementsByName('onoffswitch');
	if(retValArray[2] == "true")	useProxy[2].checked = true;
	else							useProxy[2].checked = false;
}

function extConfo_ip_focus() {
	document.getElementById('extConfo_ip').focus();
}

function extConfo_port_focus() {
	document.getElementById('extConfo_port').focus();
}

// 외부접속 정보 저장
function saveExtSet() {
	$('#extConfoForm').fadeOut(500);
	$('#settingForm').fadeIn(500);

	var ip = $('#extConfo_ip').val();
	var port = $('#extConfo_port').val();
	var useProxy = document.getElementsByName('onoffswitch');
    SetlocalStorage("ip", ip);
    SetlocalStorage("proxyPort", port);
    SetlocalStorage("useProxy", useProxy[2].checked);
    //	Proxy.save(function(){}, function(e) {
//		navigator.notification.alert(extConfo_alert_save_fail+ ": "+ e, function(){}, 'Setting', 'OK');
//	}, ip, port, useProxy[2].checked);
}
