/*
 * logincheck() -> login()
 */
function login(id, password, LoginType) {
    try{
	SetsessionStorage("offline", "false");
	SetsessionStorage("UserID", id);
	SetlocalStorage("id", id);
        

	LoginSession = getDate();
	SetlocalStorage("LoginSession", LoginSession);
	SetsessionStorage("LoginType", LoginType);
	Agent = GetlocalStorage("Platform");
    use_local_disk =  GetlocalStorage("use_local_disk");
        
/*
    try{
	window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, function(fileSystem) {
		path = "/" + fileSystem.root.name + "/ECM/dcrypt_tmp";
		window.resolveLocalFileSystemURI("file://"+path, function(directoryentry) {
			directoryentry.removeRecursively("", "");
		}, null);
	}, null);
*/
	server = GetlocalStorage("webserver");
	tmpDeviceID = GetlocalStorage("DeviceID");
	/* SSL Port로 접속시, 현재 접속 불가(Error)
	 * ServerInfo = server + "\t" +GetlocalStorage("SSL") + "\t" + GetlocalStorage("port") + "\t" + GetlocalStorage("SSLPort")+ "\t" + GetlocalStorage("PollingPeriod");
	 */
	ServerInfo = server + "\t" + GetlocalStorage("port") + "\t" + GetlocalStorage("PollingPeriod");
	DeviceInfo = device.name + "\t" + device.platform +"\t" + tmpDeviceID + "\t" + device.version;
	SetlocalStorage("ServerInfo", ServerInfo);
	SetlocalStorage("DeviceInfo", DeviceInfo);
	paraData = use_local_disk + "\t" + ServerInfo + "\t" + DeviceInfo + "\t" + LoginType + "\t" + id + "\t" + password + "\t" +  "no\t" + Agent;
	cryptutil = new CryptUtil();
	cryptutil.login(success, fail, paraData, LoginSession);
    }catch(e){
        alert('login err = ' + e);
    }
}

/*
 * logincheck() -> login() -> getDate()
 */
function getDate() {
	var now = new Date();
	var year = now.getFullYear().toString();
	var month = (now.getMonth()+1).toString();
	var day = now.getDay().toString();
	var hour = now.getHours().toString();
	var min = now.getMinutes().toString();
	var sec = now.getSeconds().toString();

	if (month.length == 1) month = "0" + month;
	if (day.length == 1) day = "0" + day;
	if (hour.length == 1) hour = "0" + hour;
	if (min.length == 1) min = "0" + min;
	if (sec.length == 1) sec = "0" + sec;

	return year + month + day + hour + min + sec;
}

/*
 * logincheck() -> login() -> success()
 */
function success(r) {
	loginRetArr = new Array();
	loginRetArr = r.split("\t");
	protocol = GetlocalStorage("protocol");	 
	port = GetlocalStorage("port");	 
	server = GetlocalStorage("webserver");

    if(GetlocalStorage("auto") == "true") {
        SetsessionStorage("autoPassword", loginRetArr[6]);
        if(GetlocalStorage("autoPassword", "") != "" && GetlocalStorage("autoPassword", "") != "null" && GetlocalStorage("autoPassword", "") != null) {
            loginRetArr[6] = GetlocalStorage("autoPassword", "");
        }
    }
    else    SetlocalStorage("autoPassword", "");
    
//	SetlocalStorage("UserID", loginRetArr[5]);
	SetlocalStorage("Password", loginRetArr[6]);

    authID = GetlocalStorage("UserID");
    AuthKey = GetlocalStorage("AuthKey");
    AuthMac = GetlocalStorage("mac");
    serviceID = GetlocalStorage("serviceID");
    
	tmpparaData = "DeviceName=" + loginRetArr[0] + ";DevicePlatform=" + loginRetArr[1] + ";DeviceID=" + loginRetArr[2] + ";DeviceVersion=" + loginRetArr[3] +
		";LoginType=" + loginRetArr[4] + ";User=" + loginRetArr[5] + ";Password=" + loginRetArr[6] + ";AdminType=" + loginRetArr[7];	 
	tmpCookie = "PlusVersion=version 1.0"+ ";LoginSession="+ loginRetArr[9] + ";Agent="+ loginRetArr[8];
    LoginparaData = "Server="+server+"&Port="+port+"&Url="+"/clientsvc/Login.jsp"+"&CookieData="+tmpCookie+"&ParamData="+tmpparaData+"&AccountId="+authID+"&AuthKey="+AuthKey+"&mac="+AuthMac+"&serviceID="+serviceID;
    
    useProxy = GetlocalStorage("useProxy");
//    useProxy = "true";
    if(useProxy == "true"){
        us = new ProxyConnect();
        us.proxyconn(SuccessLogin, function(){alert('fail');}, protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", LoginparaData);
    } else {
        LoginRetVal = AjaxRequest(protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", LoginparaData);
        CheckRetVal(LoginRetVal, server);
    }
}

function SuccessLogin(LoginRetVal){
    CheckRetVal(LoginRetVal, server);
}

/*
 * logincheck() -> login() -> fail()
 */
function fail(e) {
	navigator.notification.alert(
			"Login Fail : " + e,
			null,
			'Explorer',
			'OK'
	);
}

/*
 * logincheck() -> login() -> success() -> CheckRetVal()
 */
function CheckRetVal(LoginRetVal, server) {
	var checkretvalArr = new Array();
	checkretvalArr = LoginRetVal.split("\r\n");
	if("version 1.0" == checkretvalArr[0].toLowerCase()) {
		if("success" == checkretvalArr[1].toLowerCase()) {
            try{
			var userInfo = new Array();
                
			userInfo = checkretvalArr[2].split("\t");
                
            SetlocalStorage("FileHttpPort", userInfo[0]);
			SetlocalStorage("FileSSlPort", userInfo[1]);
			SetlocalStorage("DomainID", userInfo[2]);

            var tempAutoPassword = GetlocalStorage("autoPassword", "");
            if(tempAutoPassword == null || tempAutoPassword == "null" || tempAutoPassword == "")
                SetlocalStorage("autoPassword", GetsessionStorage("autoPassword"));
			//GetLogoImg();		// 2016.02.22 모바일 UI변경 후, 필요가 없어보임.
			// MQTT broker 접속
//			brokerIP= "1.212.69.220";
//			brokerPORT= "53335";
//			topics= "/test5";
//                ServiceCode = userInfo[21];
//                MQTTtoken = userInfo[22];
//			pp = new MQTTPlugin();
//			pp.connect("", function(e){alert("Connect push service ERR: "+ e)}, brokerIP, brokerPORT, GetlocalStorage("id"), topics, ServiceCode, MQTTtoken);
            }catch(e){
                alert('err = ' + e);
            }
            try{
                getDriveList(accountID);
//			document.location.href="explorer.html";
            }catch(e){
                alert('err = ' + e);
            }
		} else if("need approval" == checkretvalArr[1].toLowerCase()) {
			alertMessage(checkretvalArr[1].toLowerCase());
		} else if("not exist device" == checkretvalArr[1].toLowerCase()) {
			alertMessage(checkretvalArr[1].toLowerCase());
		} else if("lost device" == checkretvalArr[1].toLowerCase()) {
			server = GetlocalStorage("webserver");
			siteid = GetlocalStorage("SiteID");
			port = GetlocalStorage("port");
			server = server + ":" + port;

			var devicestatus = new DeviceStatus();
			devicestatus.deletefiles(SuccessMsg, FailMsg, server, siteid);
		} else if("stop device" == checkretvalArr[1].toLowerCase()) {
			server = GetlocalStorage("webserver");
			siteid = GetlocalStorage("SiteID");
			port = GetlocalStorage("port");
			server = server + ":" + port;

			var devicestatus = new DeviceStatus();
			devicestatus.locationinfo(SuccessMsg, FailMsg, server, siteid);
		} else if("not exists" == checkretvalArr[1].toLowerCase()) {
			navigator.notification.alert(login_alert_not_exist, null, login_alert_title, 'OK');
		} else {
			alertMessage(checkretvalArr[1].toLowerCase());
		}
	}
}

/*
 * logincheck() -> login() -> success() -> CheckRetVal() -> SuccessMsg()
 */
function SuccessMsg(r) {
	r = decodeURIComponent(r);
	alertMessage(r.toLowerCase());
}

/*
 * logincheck() -> login() -> success() -> CheckRetVal() -> FailMsg()
 */
function FailMsg(r) {
	r = decodeURIComponent(r);
	alertMessage(r.toLowerCase());
}

// GetLogoImg(), successImg() 삭제 - 2016.02.22

/* 오프라인 로그인
 * logincheck() -> login() -> offlineLogin()
 */
function offlineLogin(id, password) {
	SetsessionStorage("offline", "true");
	SetsessionStorage("UserID", id);
	ServerInfo = GetlocalStorage("ServerInfo");
	DeviceInfo = GetlocalStorage("DeviceInfo");
	Agent = GetlocalStorage("Platform");
	value = ServerInfo + "\t" + DeviceInfo + "\t" + "Normal" + "\t" + id + "\t" + password + "\t" +  "no\t" + Agent;
	loginSession = GetlocalStorage("LoginSession");
	
	cryptutil = new CryptUtil();
	cryptutil.login(function(r) {
		loginRetArr= new Array();
		loginRetArr= r.split("\t");

		userid= GetlocalStorage("UserID");
		pass= GetlocalStorage("Password");
		if(loginRetArr[5] == userid && loginRetArr[6] == pass) {
			document.location.href="explorer.html";
		}
		else
			navigator.notification.alert("Fail", "", 'Login', 'OK');
	}, function(e) {
		navigator.notification.alert("Fail", "", 'Login', 'OK');
	}, value, loginSession);
}
