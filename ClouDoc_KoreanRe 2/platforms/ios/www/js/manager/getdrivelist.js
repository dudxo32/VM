var nowPage = "";
var tmpCheckedList = new Array();
var tmpCheckedListAttribute = new Array();
var tmpAction = "";
var tmpWebServer = "";
var tmpDriveName = "";
var tmpFileServer = "";
var tmpFileServerPort = "";
var tmpPartition = "";
var tmpDiskType = "";
var paraDiskType = "";
var tmpOwner = "";
var tmpStartPath = "";
var tmpUserPath = "";
var tmpShareUser = "";
var tmpShareOwner = "";
var tmpSharePath = "";
var tmpSortFlag = "";
var tmpPermission = "";
var tmpTreeID = "";
var tmpLocalTreeID = "local_tree_0";
var tmpLocalRootPath = "";
var tmpLocalUserPath = "";
var tmpSubtree = "";
var tmpDomainID = GetlocalStorage("DomainID");
var tmpOrgCode = "0";
var tmpfilename = "";
var tmpfilesize = "";
var ECMFolder = "ECM/data";
var tmpAgent = "";
var saveFileServer = "";
var saveFileServerPort = "";
var savePartition = "";
var saveDiskType = "";
var saveOwner = "";
var saveStartPath = "";
var saveUserPath = "";
var saveShareUser = "";
var saveShareOwner = "";
var saveSharePath = "";
var saveParamVal = "";

var multipleFlag = "";
var copyFlag = "";
var moveFlag = "";

var downfile = 0;
var downfileoverwrite = 0;
var downfileoffset = 0;
var upfile = 0; 
var upfileoverwrite = 0;
var upfileoffset = 0;
var cameraFlag = "";
var checkwifi = false;

var lang_alert_delete = "";
//reg_device
var lang_alert_success_reg_device = "";
var lang_alert_needs_approval_reg_device = "";
var lang_alert_already_exist_reg_device = "";
var lang_alert_not_exist_user_reg_device = "";
var lang_alert_exceeds_number_reg_device = "";
var lang_alert_wrong_user_iofo_reg_device = "";
//login
var lang_alert_insert_server = "";
var lang_alert_insert_id = "";
var lang_alert_insert_password = "";
var lang_parameter_missing = "";
var lang_login_fail_create_home = "";
var lang_login_insert_info = "";
var lang_login_domain_disk_overflow = "";
var lang_login_stop_device = "";
var lang_login_lost_device = "";
var lang_login_not_exist_device = "";
var lang_index_simple_script_null_server = "";
var lang_server_error = "";
var lang_status_stop = "";
var lang_login_incorrect_password = "";
var lang_login_password_expire = "";
var lang_login_guest_expire = "";
var lang_login_not_allowed_agent = "";
var lang_exception_error = "";
var lang_ip_filtered = "";
var lang_server_busy = "";
var lang_user_busy = "";
var lang_access_denied = "";
var lang_invalid_parameter = "";
var lang_disk_overflow = "";
var lang_already_folder_exists = "";
var lang_already_file_error = "";
var lang_guest_root = "";
var lang_sharing_violation = "";
var lang_guest_data_root = "";
var lang_already_file_exists = "";
var lang_already_folder_error = "";
var lang_has_acl_folder = "";
var lang_has_share_folder = "";
var lang_substree_exists = "";
var lang_filename_filtered = "";
var lang_download_busy = "";
var lang_download_limit = "";
var lang_license_expired = "";
var lang_upload_limit = "";
var lang_upload_busy = "";
var lang_partial_success = "";
var lang_not_exists = "";
var lang_alert_not_exists_path = "";
var lang_alert_overwrite = "";
var lang_alert_offset = "";
var lang_alert_not_support_format = "";
var lang_confrim_wifi = "";
var lang_alert_not_exists_Officesuite = "";
var lang_confirm_CloseTheApp = "";
var lang_login_not_exists = "";

var accountID = "";
var GetObj = "";
var GetObjBefore = "";
var firstSort = 0;
var nowDriveName = "none";
var beforeDriveName = "none";
var fileOpenFlag = 0;
var pdfStartPath = "";
var nowMode = "";

var isSplit = "";
var tmpTabletInfoData = "";

var savetreeid = "";
var savefoldername = "";
var saveowner = "";
var saveserver = "";
var savepartiton = "";
var savestartpath = "";
var saveuserpath = "";
var savedisktype = "";
var saveshareuser = "";
var savesharepath = "";

function getDriveList(accountID) {
    if(nowFunc == "multiple") {
        singleMode();
        nowFunc = "getDriveList";
    }
    $('#multipleBtnImg').css('display', 'none');
    $('#sortBtn_modal').css('display', 'none');
    restoreExplorerForm();
    nowPage = "server";
    tmpTreeID = "";
    tmpUserPath = "";

	User = GetsessionStorage("UserID");
	UserType= GetsessionStorage("LoginType");
	OSLang = GetlocalStorage("OSLang");
    
    UserType = "Normal";
    
	if(OSLang == "kor") LangID = "0412";
	else if(OSLang == "chn") LangID = "0804";
	else if(OSLang == "jpn") LangID = "0411";
	else LangID = "0409";

    tmpDomainID = GetlocalStorage("DomainID");
    
	parameter = User + "\t" + UserType + "\t" + tmpDomainID + "\t" + LangID;
    
    try{
	cryptutil = new CryptUtil();
	cryptutil.call(SuccessGetDriveList, "", parameter, GetlocalStorage("SiteID"));
    }catch(e){
        cryptutil.call(SuccessGetDriveList, "", parameter, GetlocalStorage("SiteID"));
    }
}

function SuccessGetDriveList(r) {
    try{
    if(multipleFlag == "true" && copyFlag != "true" && moveFlag != "true"){
        singleMode();
        multipleFlag = "false";
    }
	protocol = GetlocalStorage("protocol");
	server = GetlocalStorage("webserver");
	port = GetlocalStorage("port");
    tmpUserPath = "";
	tmpWebServer = server;
	RetArr = new Array();
	RetArr = r.split("\t");

    authID = GetlocalStorage("UserID");
    AuthKey = GetlocalStorage("AuthKey");
    AuthMac = GetlocalStorage("mac");
    serviceID = GetlocalStorage("serviceID");
        
	tmpparaData = "User=" + RetArr[0] + ";UserType=" + RetArr[1];
	tmpCookie = "DomainID="+ RetArr[2] + ";LangID="+ RetArr[3];
    paraData = "Server="+server+"&Port="+port+"&Url="+"/clientsvc/GetDriveList.jsp"+"&CookieData="+tmpCookie+"&ParamData="+tmpparaData+"&AccountId="+authID+"&AuthKey="+AuthKey+"&mac="+AuthMac+"&serviceID="+serviceID;
    
//    useProxy = GetlocalStorage("useProxy");
//    if(useProxy == "true"){
//        us = new ProxyConnect();
//        us.proxyconn(SuccessDrive, function(){alert('fail');}, protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);
//    } else {
//        RetVal = AjaxRequest(protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);
//        reciveGetDriveList(RetVal);
//    }
//    AM = new AppManager();
//    AM.auth_check(check_GetDrive,null);
    check_GetDrive();
    }catch(e){
        alert('err = ' + e);
    }
}

function check_GetDrive(){
    useProxy = GetlocalStorage("useProxy");
    if(useProxy == "true"){
//        useProxy = "true";
        us = new ProxyConnect();
        us.proxyconn(SuccessDrive, function(){alert('fail');}, protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);
    } else {
        RetVal = AjaxRequest(protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);

        reciveGetDriveList(RetVal);
    }
}

function SuccessDrive(RetVal){
    reciveGetDriveList(RetVal);
}

function reciveGetDriveList(data) {
    $(".contents-title > div:nth-child(3)").hide();
    
//    result = data.substring((data.indexOf("\r\n")) + 2);
    result = data.split("version 1.0\r\n");
    result = result[result.length-1];
    
    if("Success" != result.substring(0, 7)){
        if(result != "Auth Fail" && result != "etwork Err"){
            if(result == "etwork Error"){
                navigator.notification.alert("네트워크 연결 상태를 확인 후\n이용해 주세요.", function(){}, "", "확인");
            } else {
                navigator.notification.alert(result, function(){}, "", "확인");
            }
        }
        return;
    }
    
    var getDriveListResult = data.split("\r\n");
    var personalDriveInfo = getDriveListResult[2].split("\t");
    var personalTreeID = "T_" + personalDriveInfo[9] + "_" + personalDriveInfo[0];
    var shareDriveInfo = getDriveListResult[3].split("\t");
    var shareTreeID = "T_" + shareDriveInfo[9] + "_" + shareDriveInfo[0];
    var treeTarget = $("nav > div:nth-child(2)");
    
    $(".list").remove();
    $("nav > div:nth-child(2) > *").remove();
    $(".contents-title").first().find("div:nth-child(2) img").attr("src", "images/icon/cont-title-03.png");
    $(".contents-title").first().find("div:nth-child(2) label:nth-child(2)").text("문서함");
    $("#NetID_currentFolder").text("");
    
    // Tree menu
    for ( var index = 2; index < getDriveListResult.length; index++ ) {
        var driveInfo = getDriveListResult[index].split("\t");
        var treeID = "T/" + driveInfo[9] + "/" + driveInfo[0];
        
        if ( driveInfo[9] == "orgcowork" )
        {
            treeTarget.append("<div id='" + treeID + "' class='tree-drive tree-close' value='" + driveInfo[9] + "' onclick=\"downFolerDrive('" + treeID + "', '" + driveInfo[0] + "', '" + driveInfo[2] + "', '" + driveInfo[4] + "', '" + driveInfo[5] + "', '" + driveInfo[6] + "', '" + driveInfo[9] + "', '" + driveInfo[7] + "', 'no')\"><label class='imgLabel' onclick=\"treeManager('drive', '" + treeID + "', '" + driveInfo[0] + "', '" + driveInfo[2] + "', '" + driveInfo[4] + "', '" + driveInfo[5] + "', '" + driveInfo[6] + "', '" + driveInfo[9] + "', '', '" + driveInfo[7] + "', 'no')\"></label><img src='images/icon/nav-folder-05.png' width='25px'><label>" + driveInfo[0] + "(Q)</label><span></span></div>");
            $(".contents-list").append("<div class='list list-drive' ontouchstart='touchStart(this)' ontouchend='touchEnd(this)' ontouchmove='touchEnd(this)' onclick=\"downFolerDrive('" + treeID + "', '" + driveInfo[0] + "', '" + driveInfo[2] + "', '" + driveInfo[4] + "', '" + driveInfo[5] + "', '" + driveInfo[6] + "', '" + driveInfo[9] + "', '" + driveInfo[7] + "', 'no')\"><img src='images/icon/cont-title-02.png'><label>" + driveInfo[0] + "(Q)</label></div>");
        }
        else
        {
            treeTarget.append("<div id='" + treeID + "' class='tree-drive tree-close' value='" + driveInfo[9] + "' onclick=\"downFolerDrive('" + treeID + "', '" + driveInfo[0] + "', '" + driveInfo[2] + "', '" + driveInfo[4] + "', '" + driveInfo[5] + "', '" + driveInfo[6] + "', '" + driveInfo[9] + "', '" + driveInfo[7] + "', 'no')\"><label class='imgLabel' onclick=\"treeManager('drive', '" + treeID + "', '" + driveInfo[0] + "', '" + driveInfo[2] + "', '" + driveInfo[4] + "', '" + driveInfo[5] + "', '" + driveInfo[6] + "', '" + driveInfo[9] + "', '', '" + driveInfo[7] + "', 'no')\"></label><img src='images/icon/nav-folder-02.png' width='25px'><label>" + driveInfo[0] + "(P)</label><span></span></div>");
            $(".contents-list").append("<div class='list list-drive' ontouchstart='touchStart(this)' ontouchend='touchEnd(this)' ontouchmove='touchEnd(this)' onclick=\"downFolerDrive('" + treeID + "', '" + driveInfo[0] + "', '" + driveInfo[2] + "', '" + driveInfo[4] + "', '" + driveInfo[5] + "', '" + driveInfo[6] + "', '" + driveInfo[9] + "', '" + driveInfo[7] + "', 'no')\"><img src='images/icon/cont-title-01.png'><label>" + driveInfo[0] + "(P)</label></div>");
        }
    }

    treeTarget.find("label:nth-child(1)").click(function(evt){evt.stopPropagation();});
    pdfStartPath = personalDriveInfo[6];
}
