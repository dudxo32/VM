/* Server 정보 가져오기
 * logincheck() -> getserverinfo()
 */
function getserverinfo(protocol, port, server) {
	if(port == "" || port == null) port = "80";
	if(protocol == "" || protocol == null) protocol = "http";
	SetlocalStorage("protocol", protocol);
	SetlocalStorage("port", port);
	SetlocalStorage("webserver", server);
	GetPollingPeriod = "";
	if("12" == GetlocalStorage("Platform")) GetPollingPeriod = "yes";
	else GetPollingPeriod = "no";
	retValue = "";

    authID = GetlocalStorage("UserID");
    AuthKey = GetlocalStorage("AuthKey");
    AuthMac = GetlocalStorage("mac");
    serviceID = GetlocalStorage("serviceID");
    
	tmpparaData = "GetPollingPeriod="+ GetPollingPeriod;
    ServerInfoData = "Server="+server+"&Port="+port+"&Url="+"/clientsvc/GetServerInfo.jsp"+"&ParamData="+tmpparaData+"&AccountId="+authID+"&AuthKey="+AuthKey+"&mac="+AuthMac+"&serviceID="+serviceID;

    useProxy = GetlocalStorage("useProxy");
//    useProxy = "true";
    if(useProxy == "true"){
        us = new ProxyConnect();
        us.proxyconn(getServer, function(){alert('fail');}, protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", ServerInfoData);
    } else {
        retValue = AjaxRequest(protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", ServerInfoData);
        retValueArr = new Array();
        retValueArr = retValue.split("\r\n");
        if("version 1.0" == retValueArr[0].toLowerCase()) {
            $('#loadingPage').hide();
            if("success" == retValueArr[1].toLowerCase()) {
                for(var i= 2; i < retValueArr.length; i++) {
                    var serverinfo = new Array();
                    serverinfo = retValueArr[i].split("\t");
                    
                    if(serverinfo[0] == "SupportInfo")	SetlocalStorage(serverinfo[0], serverinfo[1]);
                    if(serverinfo[0] == "SiteName") 	SetlocalStorage(serverinfo[0], serverinfo[1]);
                    if(serverinfo[0] == "SiteID")		SetlocalStorage(serverinfo[0], serverinfo[1]);
                    if(serverinfo[0] == "ShowDiskType")	SetlocalStorage(serverinfo[0], serverinfo[1]);
                    if(serverinfo[0] == "nClientConfigs")	SetlocalStorage(serverinfo[0], serverinfo[1]);
                    if(serverinfo[0] == "PollingPeriod")	SetlocalStorage(serverinfo[0], serverinfo[1]);
                }
            }
            else	{
                if(result != "Auth Fail" && result != "etwork Err"){
                    alertMessage(retValueArr[1].toLowerCase());
                }
                AM = new AppManager();
                setTimeout(function(){
                           AM.auth_get();
                           AM.finishapp();
                           }, 1000);
            }
        }
    }
}

function getServer(retValue){
    retValueArr = new Array();
    retValueArr = retValue.split("\r\n");
    if("version 1.0" == retValueArr[0].toLowerCase()) {
        if("success" == retValueArr[1].toLowerCase()) {
            for(var i= 2; i < retValueArr.length; i++) {
                var serverinfo = new Array();
                serverinfo = retValueArr[i].split("\t");
                
                if(serverinfo[0] == "SupportInfo")	SetlocalStorage(serverinfo[0], serverinfo[1]);
                if(serverinfo[0] == "SiteName") 	SetlocalStorage(serverinfo[0], serverinfo[1]);
                if(serverinfo[0] == "SiteID")		SetlocalStorage(serverinfo[0], serverinfo[1]);
                if(serverinfo[0] == "ShowDiskType")	SetlocalStorage(serverinfo[0], serverinfo[1]);
                if(serverinfo[0] == "nClientConfigs")	SetlocalStorage(serverinfo[0], serverinfo[1]);
                if(serverinfo[0] == "PollingPeriod")	SetlocalStorage(serverinfo[0], serverinfo[1]);
            }
        }
        else	alertMessage(retValueArr[1].toLowerCase());
    }
}

/* Server로부터 Device기능 옵션값 가져오기
 * logincheck() -> gettabletinfo()
 */
function gettabletinfo(protocol, port, server) {
 	if(port == "" || port == null) port = "80";
	if(protocol == "" || protocol == null) protocol = "http";
	SetlocalStorage("protocol", protocol);
	SetlocalStorage("port", port);
	SetlocalStorage("webserver", server);
	GetPollingPeriod = "";
	if("12" == GetlocalStorage("Platform")) GetPollingPeriod = "yes";
	else GetPollingPeriod = "no";
	OSLang = GetlocalStorage("OSLang");
	retValue = "";

    authID = GetlocalStorage("UserID");
    AuthKey = GetlocalStorage("AuthKey");
    AuthMac = GetlocalStorage("mac");
    serviceID = GetlocalStorage("serviceID");
    
    
	tmpparaData = "GetPollingPeriod="+ GetPollingPeriod+";OSLang="+OSLang;
    TabletInfoData = "Server="+server+"&Port="+port+"&Url="+"/webapp/GetTabletInfo.jsp"+"&ParamData="+tmpparaData+"&AccountId="+authID+"&AuthKey="+AuthKey+"&mac="+AuthMac+"&serviceID="+serviceID;
    
    useProxy = GetlocalStorage("useProxy");
    
//    useProxy = "true";
    if(useProxy == "true"){
        us = new ProxyConnect();
        us.proxyconn(getTablet, function(){alert('fail');}, protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", TabletInfoData);
    } else {
        retValue = AjaxRequest(protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", TabletInfoData);
        
        retValueArr = new Array();
        retValueArr = retValue.split("\r\n");
        if("version 1.0" == retValueArr[0].toLowerCase()) {
            if("success" == retValueArr[1].toLowerCase()) {
                for(var i = 2; i < retValueArr.length; i++) {
                    var tabletinfo = new Array();
                    tabletinfo = retValueArr[i].split("\t");
                    
                    if(tabletinfo[0] == "copyright")	SetlocalStorage(tabletinfo[0], tabletinfo[1]);
                    if(tabletinfo[0] == "file_open")	SetlocalStorage(tabletinfo[0], tabletinfo[1]);
                    if(tabletinfo[0] == "use_local_disk")	SetlocalStorage(tabletinfo[0], tabletinfo[1]);
                    if(tabletinfo[0] == "use_mobile_tree")	SetlocalStorage(tabletinfo[0], tabletinfo[1]);
                    if(tabletinfo[0] == "use_camera")	SetlocalStorage(tabletinfo[0], tabletinfo[1]);
                    if(tabletinfo[0] == "doc_lang")		SetlocalStorage(tabletinfo[0], tabletinfo[1]);
                    if(tabletinfo[0] == "PollingPeriod")	SetlocalStorage(tabletinfo[0], tabletinfo[1]);
                }
            }
            else{
                if(result != "Auth Fail" && result != "etwork Err"){
                    alertMessage(retValueArr[1].toLowerCase());
                }
                AM = new AppManager();
                setTimeout(function(){
                           AM.auth_get();
                           AM.finishapp();
                           }, 1000);
            }
        }
    }
    
    tmpTabletInfoData = TabletInfoData;
    
    setInterval(function() {
                retValue = AjaxRequest(protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", TabletInfoData);
                }, 120000);
}

function getTablet(retValue){
    retValueArr = new Array();
    retValueArr = retValue.split("\r\n");
    if("version 1.0" == retValueArr[0].toLowerCase()) {
        if("success" == retValueArr[1].toLowerCase()) {
            for(var i = 2; i < retValueArr.length; i++) {
                var tabletinfo = new Array();
                tabletinfo = retValueArr[i].split("\t");
                
                if(tabletinfo[0] == "copyright")	SetlocalStorage(tabletinfo[0], tabletinfo[1]);
                if(tabletinfo[0] == "file_open")	SetlocalStorage(tabletinfo[0], tabletinfo[1]);
                if(tabletinfo[0] == "use_local_disk")	SetlocalStorage(tabletinfo[0], tabletinfo[1]);
                if(tabletinfo[0] == "use_mobile_tree")	SetlocalStorage(tabletinfo[0], tabletinfo[1]);
                if(tabletinfo[0] == "use_camera")	SetlocalStorage(tabletinfo[0], tabletinfo[1]);
                if(tabletinfo[0] == "doc_lang")		SetlocalStorage(tabletinfo[0], tabletinfo[1]);
                if(tabletinfo[0] == "PollingPeriod")	SetlocalStorage(tabletinfo[0], tabletinfo[1]);
            }
        }
        else	alertMessage(retValueArr[1].toLowerCase());
    }
}
