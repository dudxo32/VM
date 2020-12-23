var save_disktype = "";

// 드라이브 들어가기
function downFolerDrive(treeid, drivename, owner, server, partiton, startpath, disktype, orgcode, subtree) {
    $(".tree-drive-selected").removeClass("tree-drive-selected");
    $(".BM-selected").removeClass("BM-selected");
    if ( disktype == "personal" )
    {
        $(".tree-drive").first().addClass("tree-drive-selected");
        $(".contents-title").first().find("div:nth-child(2) img").attr("src", "images/icon/cont-title-01.png");
        $(".contents-title").first().find("div:nth-child(2) label:nth-child(2)").text("개인문서함");
    }
    else
    {
        $(".tree-drive").last().addClass("tree-drive-selected");
        $(".contents-title").first().find("div:nth-child(2) img").attr("src", "images/icon/cont-title-02.png");
        $(".contents-title").first().find("div:nth-child(2) label:nth-child(2)").text("공유문서함");
    }
    
    //    $('#multipleBtnImg').css('display', 'block');
    //    $('#sortBtn_modal').css('display', 'table-cell');
    //    $("#currentFolder").text(drivename);
    nowDriveName = drivename;

    tmpTreeID = treeid;
    tmpDriveName = drivename;
    tmpOwner = owner;
    tmpFileServer = server;
    tmpPartition = partiton;
    tmpStartPath = startpath;
    tmpUserPath = "/";
    tmpSubtree = subtree;
    User = GetsessionStorage("UserID");
    Agent = GetlocalStorage("Platform");
    para = tmpUserPath + "\t" + tmpSubtree;
    paraDiskType = disktype;
    saveParamVal = disktype + "\t" + orgcode;
    saveParam = "saveParam" + owner;
    SetsessionStorage(saveParam, saveParamVal);
    option = "";
    
    loginType= GetsessionStorage("LoginType");
    /* 기존 option값 지정 source-code(2016.02.26 수정)
     * disktype이 server에서 "personal"로만 내려오기에
     * 기준값을 disktype이 아닌, LoginType으로 수정
     if(paraDiskType == "personal") option = "0x01";*/
    if(loginType == "Normal")	option = "0x01";
    else if(loginType == "GuestID")	option = "0x03";
    
    if(disktype == "share") {
        tmpStartPath = "/";
        para = "/\tno";
        tmpDiskType = "OrgCoworkShare";
        tmpShareUser = "";
        tmpSharePath = "";
        tmpShareOwner = "";
    }
    else
        tmpDiskType = "OrgCowork";
    save_disktype = disktype;
    if(disktype == "orgcowork") option = " ";
    
    cookie = tmpDomainID + "\t" + tmpDiskType + "\t" + User + "\t" + tmpPartition + "\t" + tmpWebServer + "\t" + Agent + "\t" + option + "\t" + tmpOwner + "\t" + tmpShareUser + "\t" + tmpShareOwner + "\t" + tmpStartPath;
    parameter = para + "\t" + cookie;
    
    //  parameter = / no 1000000000000 OrgCowork asdf1 c_home 192.168.1.185 12 0x0100000 /asdf1(asdf1)
    try{
        cryptutil = new CryptUtil();
        cryptutil.call(SuccessGetList, "", parameter, GetlocalStorage("SiteID"));
    }catch(e){
        cryptutil.call(SuccessGetList, "", parameter, GetlocalStorage("SiteID"));
    }
    SetlocalStorage("clickDrive", 1);
    
}

function menuDownFolerDrive(treeid, drivename, owner, server, partiton, startpath, disktype, orgcode, subtree) {
    try{
        nowDriveName = drivename;
        SetlocalStorage("clickDrive", 1);
        nowPage= "server";
        tmpUserPath = "";
        //	$('#explorer_lang_title').text(explorer_lang_title_server);
        //	$('#work_lang_title').text(explorer_lang_title_server);
        //	$("#currentFolder").text("Server");
        //	$('#explorerList li').remove();
        
        //    closeMenu();
        downFolerDrive(treeid, drivename, owner, server, partiton, startpath, disktype, orgcode, subtree);
    }catch(e){
        alert('err = ' + e);
    }
}

// Server내 하위폴더 이동
function downFolder(treeid, foldername, owner, server, partiton, startpath, userpath, disktype, shareuser, sharepath){
    if(save_disktype == "personal" && partiton == "z_orgcowork"){
        SetlocalStorage("clickDrive", 1);
        save_disktype = "orgcowork";
        nowDriveName = "공유문서함"
    } else if(save_disktype == "orgcowork" && partiton == "z_home"){
        SetlocalStorage("clickDrive", 1);
        save_disktype = "personal";
        nowDriveName = "개인문서함";
    }
    
    $(".tree-drive-selected").removeClass("tree-drive-selected");
    $(".BM-selected").removeClass("BM-selected");
    
    if ( partiton == "z_home" )
    {
        paraDiskType = "personal";
        $(".contents-title").first().find("div:nth-child(2) img").attr("src", "images/icon/cont-title-01.png");
        $(".contents-title").first().find("div:nth-child(2) label:nth-child(2)").text("개인문서함");
    }
    else
    {
        paraDiskType = "orgcowork";
        $(".contents-title").first().find("div:nth-child(2) img").attr("src", "images/icon/cont-title-02.png");
        $(".contents-title").first().find("div:nth-child(2) label:nth-child(2)").text("공유문서함");
    }
    
    tmpTreeID = treeid;
    
    tmpFileServer = server;
    tmpPartition = partiton;
    tmpDiskType = disktype;
    tmpOwner = owner;
    tmpStartPath = startpath;
    tmpFolderName = foldername = foldername.indexOf("NetID_apostrophe") > -1?   foldername.replace(/NetID_apostrophe/gi, '\'') : foldername;
    userpath = userpath.indexOf("NetID_apostrophe") > -1?   userpath.replace(/NetID_apostrophe/gi, '\'') : userpath;
    tmpUserPath = (userpath+"/"+foldername).replace("//", "/");
    tmpShareUser = shareuser;
    tmpShareOwner = sharepath;
    
    para = tmpUserPath + "\t" + tmpSubtree;
    Agent = GetlocalStorage("Platform");
    option = "";
    if(paraDiskType == "personal") option = "0x01";
    else option = "0x00";
    
    if(disktype == "OrgCoworkShare"){
        tmpDiskType = "OrgCoworkShare";
    }    
    else
        tmpDiskType = "OrgCowork";
    
    if(save_disktype == "orgcowork") option = " ";
    if(tmpPartition == "z_orgcowork"){
        option = " ";
    } else {
        option = "0x01";
    }
    
    cookie = tmpDomainID + "\t" + tmpDiskType + "\t" + User + "\t" + tmpPartition + "\t" + tmpWebServer + "\t" +
    Agent + "\t" + option + "\t" + tmpOwner + "\t" + tmpShareUser + "\t" + tmpShareOwner + "\t" + tmpStartPath;
    parameter = para + "\t" + cookie;
    
    try{
        cryptutil = new CryptUtil();
        cryptutil.call(function(r){SuccessGetList(r)}, "", parameter, GetlocalStorage("SiteID"));
    }catch(e){
        cryptutil.call(function(r){SuccessGetList(r)}, "", parameter, GetlocalStorage("SiteID"));
    }
}

// Server내 하위폴더 이동 - 개인판서함
function downFolder2(){
    try{
    if(save_disktype == "personal" && savepartiton == "z_orgcowork"){
        SetlocalStorage("clickDrive", 1);
        save_disktype = "orgcowork";
        nowDriveName = "공유문서함"
    } else if(save_disktype == "orgcowork" && savepartiton == "z_home"){
        SetlocalStorage("clickDrive", 1);
        save_disktype = "personal";
        nowDriveName = "개인문서함";
    }
    
    $(".tree-drive-selected").removeClass("tree-drive-selected");
    if ( savepartiton == "z_home" )
    {
        paraDiskType = "personal";
        $(".contents-title").first().find("div:nth-child(2) img").attr("src", "images/icon/cont-title-01.png");
        $(".contents-title").first().find("div:nth-child(2) label:nth-child(2)").text("개인문서함");
    }
    else
    {
        paraDiskType = "orgcowork";
        $(".contents-title").first().find("div:nth-child(2) img").attr("src", "images/icon/cont-title-02.png");
        $(".contents-title").first().find("div:nth-child(2) label:nth-child(2)").text("공유문서함");
    }
    
    tmpTreeID = savetreeid;
    
    tmpFileServer = saveserver;
    tmpPartition = savepartition;
    tmpDiskType = savedisktype;
    tmpOwner = saveowner;
    tmpStartPath = savestartpath;
    tmpFolderName = savefoldername = savefoldername.indexOf("NetID_apostrophe") > -1?   savefoldername.replace(/NetID_apostrophe/gi, '\'') : savefoldername;
    saveuserpath = saveuserpath.indexOf("NetID_apostrophe") > -1?   saveuserpath.replace(/NetID_apostrophe/gi, '\'') : saveuserpath;
    tmpUserPath = (saveuserpath+"/"+savefoldername).replace("//", "/");
    tmpShareUser = saveshareuser;
    tmpShareOwner = savesharepath;
    
    para = tmpUserPath + "\t" + tmpSubtree;
    Agent = GetlocalStorage("Platform");
    option = "";
    if(paraDiskType == "personal") option = "0x01";
    
    if(savedisktype == "OrgCoworkShare"){
        tmpDiskType = "OrgCoworkShare";
    }
    else
        tmpDiskType = "OrgCowork";
    
    if(save_disktype == "orgcowork") option = " ";
    if(tmpPartition == "z_orgcowork"){
        option = " ";
    } else {
        option = "0x01";
    }
        
    cookie = tmpDomainID + "\t" + tmpDiskType + "\t" + User + "\t" + tmpPartition + "\t" + tmpWebServer + "\t" +
    Agent + "\t" + option + "\t" + tmpOwner + "\t" + tmpShareUser + "\t" + tmpShareOwner + "\t" + tmpStartPath;
    parameter = para + "\t" + cookie;
        
    try{
        cryptutil = new CryptUtil();
        cryptutil.call(function(r){SuccessGetList2(r)}, "", parameter, GetlocalStorage("SiteID"));
    }catch(e){
        cryptutil.call(function(r){SuccessGetList2(r)}, "", parameter, GetlocalStorage("SiteID"));
    }
    }catch(e){
        alert('err = ' + e);
    }
}

// Server내 상위폴더 이동
function upFolder() {
    if(tmpTreeID.split('/').length == 1) return;
    if ( tmpTreeID.split('/').length > 2 )  tmpTreeID = tmpTreeID.substring(0, (tmpTreeID.lastIndexOf('/')));
    
    if ( tmpTreeID.split('/').length <= 2 ){
        getDriveList();
    } else {
        tmpUserPath = tmpUserPath.substring(0, (tmpUserPath.lastIndexOf("/")));
        if(tmpUserPath == "")	tmpUserPath = "/";
        //    paraDiskType == "personal"? $(".tree-drive").first().addClass("tree-drive-selected") : $(".tree-drive").last().addClass("tree-drive-selected");
        
        if(tmpUserPath == "/") {
            paraDiskType == "personal"? $(".tree-drive").first().addClass("tree-drive-selected") : $(".tree-drive").last().addClass("tree-drive-selected");
        }
        
        para = tmpUserPath + "\t" + tmpSubtree;
        Agent = GetlocalStorage("Platform");
        option = "";
        /* 기존 option값 지정 source-code(2016.02.26 수정)
         * disktype이 server에서 "personal"로만 내려오기에
         * 기준값을 disktype이 아닌, LoginType으로 수정
         if(paraDiskType == "personal") option = "0x01";*/
//        if(loginType == "Normal")	option = "0x01";
//        else if(loginType == "GuestID")	option = "0x03";
        
        if(save_disktype == "orgcowork") option = " ";
        
        if(tmpPartition == "z_orgcowork"){
            option = " ";
        } else {
            option = "0x01";
        }
        
        cookie = tmpDomainID + "\t" + tmpDiskType + "\t" + User + "\t" + tmpPartition + "\t" + tmpWebServer + "\t"
        + Agent + "\t" + option + "\t" + tmpOwner + "\t" + tmpShareUser + "\t" + tmpShareOwner + "\t" + tmpStartPath;
        parameter = para + "\t" + cookie;
        
        try{
            cryptutil = new CryptUtil();
            cryptutil.call(function(r){SuccessGetList(r)}, "", parameter, GetlocalStorage("SiteID"));
        }catch(e){
            cryptutil.call(function(r){SuccessGetList(r)}, "", parameter, GetlocalStorage("SiteID"));
        }
    }
}

function checkAuth(){
    var retVal = AjaxRequest(protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", tmpTabletInfoData);
    
    checkretvalArr= retVal.split("\r\n");
    
    if(checkretvalArr[1] == "Auth Fail" || checkretvalArr[1] == "etwork Err"){
//        if(checkretvalArr[1] == "Auth Fail"){
//            alert(checkretvalArr[1]);
//        }
        setTimeout(function(){
                   AM = new AppManager();
                   AM.auth_get();
                   AM.finishapp();
                   }, 1000);
    }
}

// Server 파일 재정리
function refresh() {
    $(".list").remove();
    if ( nowPage == "bookmark" ) {
        cancelEditMode(false);
        $(".BM-list").remove();
        getBMList($(".BM-selected"));
        return;
    }
    if ( tmpUserPath == "" ) {
        $("nav > div:nth-child(2) > *").remove();
        setTimeout(function(){
                   getDriveList();
                   }, 1);
        return;
    }
    para = tmpUserPath + "\t" + tmpSubtree;
    Agent = GetlocalStorage("Platform");
    option = "";
    if(paraDiskType == "personal") option = "0x01";
    cookie = tmpDomainID + "\t" + tmpDiskType + "\t" + User + "\t" + tmpPartition + "\t" + tmpWebServer + "\t"
    + Agent + "\t" + option + "\t" + tmpOwner + "\t" + tmpShareUser + "\t" + tmpShareOwner + "\t" + tmpStartPath;
    parameter = para + "\t" + cookie;
    
    setTimeout(function(){
               try{
               cryptutil = new CryptUtil();
               cryptutil.call(SuccessGetList, function(){alert('fail');}, parameter, GetlocalStorage("SiteID"));
               }catch(e){
               cryptutil.call(SuccessGetList, function(){alert('fail');}, parameter, GetlocalStorage("SiteID"));
               }
               }, 1);
}

function UploadPDF(pdfPath) {
    try{
        Agent = GetlocalStorage("Platform");''
        siteid = GetlocalStorage("SiteID");
        useSSL = GetlocalStorage("SSL");
        FileServerPort = "";
        
        if(useSSL == "yes")	FileServerPort = GetlocalStorage("FileSSlPort");
        else FileServerPort = GetlocalStorage("FileHttpPort");
        
        //    showUpDownProgressbar();
        //    upfile = setInterval(uploadprogress, 100);
        
        useProxy = GetlocalStorage("useProxy");
        
        pdfPath = pdfPath.indexOf("NetID_apostrophe") > -1?   pdfPath.replace(/NetID_apostrophe/gi, '\'') : pdfPath;
        
        updownmanager = new UpDownManager();
        updownmanager.upload(SuccessUpload, "", tmpDomainID, "personal", User, "z_home", tmpWebServer, Agent, "", "00000", tmpShareUser,
                             tmpShareOwner, pdfStartPath, tmpOrgCode, "/개인판서함", tmpFileServer, useSSL,FileServerPort, siteid, pdfPath, "", "");
    }catch(e){
        alert('err = ' + e);
    }
}

function closeBMSetting(){
    BMEditDialogManager("close");
}


// 서버로부터 암호화된 정보를 사용하여 파일목록 가져오기
function SuccessGetList(r) {
    $(".contents-title > div:nth-child(3)").show();
    protocol = GetlocalStorage("protocol");
    port = GetlocalStorage("port");
    server = GetlocalStorage("webserver");
    
    RetArr = new Array();
    RetArr = r.split("\t");
    
    tmpparaData = "SrcName=" + RetArr[0] + ";Subtree=" + RetArr[1];
    tmpCookie = "DomainID="+ RetArr[2] + ";DiskType="+ RetArr[3] + ";User="+ RetArr[4] + ";Partition="+ RetArr[5] + ";WebServer="+ RetArr[6] + ";Agent="+ RetArr[7] + ";Option="+ RetArr[8] + ";Cowork="+ RetArr[9] + ";ShareUser="+ RetArr[10] + ";SharePath="+ RetArr[11] + ";StartPath="+ RetArr[12] + ";RealIP="+ RetArr[13];
    
    authID = GetlocalStorage("UserID");
    AuthKey = GetlocalStorage("AuthKey");
    AuthMac = GetlocalStorage("mac");
    serviceID = GetlocalStorage("serviceID");
    
    paraData = "Server="+tmpFileServer+"&Port="+port+"&Url="+"/PlusDrive/GetList"+"&CookieData="+tmpCookie+"&ParamData="+tmpparaData+"&AccountId="+authID+"&AuthKey="+AuthKey+"&mac="+AuthMac+"&serviceID="+serviceID;
    
    useProxy = GetlocalStorage("useProxy");
    if(useProxy == "true"){
        us = new ProxyConnect();
        us.proxyconn(reciveGetList, function(){alert('fail');}, protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);
    } else {
        RetVal = AjaxRequest(protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);
        reciveGetList(RetVal,paraData);
    }
}

// 서버로부터 암호화된 정보를 사용하여 파일목록 가져오기 - 개인판서함
function SuccessGetList2(r) {
    protocol = GetlocalStorage("protocol");
    port = GetlocalStorage("port");
    server = GetlocalStorage("webserver");
    
    RetArr = new Array();
    RetArr = r.split("\t");
    
    tmpparaData = "SrcName=" + RetArr[0] + ";Subtree=" + RetArr[1];
    tmpCookie = "DomainID="+ RetArr[2] + ";DiskType="+ RetArr[3] + ";User="+ RetArr[4] + ";Partition="+ RetArr[5] + ";WebServer="+ RetArr[6] + ";Agent="+ RetArr[7] + ";Option="+ RetArr[8] + ";Cowork="+ RetArr[9] + ";ShareUser="+ RetArr[10] + ";SharePath="+ RetArr[11] + ";StartPath="+ RetArr[12] + ";RealIP="+ RetArr[13];
    
    authID = GetlocalStorage("UserID");
    AuthKey = GetlocalStorage("AuthKey");
    AuthMac = GetlocalStorage("mac");
    serviceID = GetlocalStorage("serviceID");
    
    paraData = "Server="+tmpFileServer+"&Port="+port+"&Url="+"/PlusDrive/GetList"+"&CookieData="+tmpCookie+"&ParamData="+tmpparaData+"&AccountId="+authID+"&AuthKey="+AuthKey+"&mac="+AuthMac+"&serviceID="+serviceID;
    
    useProxy = GetlocalStorage("useProxy");
    if(useProxy == "true"){
        us = new ProxyConnect();
        us.proxyconn(reciveGetList2, function(){alert('fail');}, protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);
    } else {
        RetVal = AjaxRequest(protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);
        try{
            cryptutil = new CryptUtil();
            cryptutil.saveParam(function(r){}, "", RetVal);
        }catch(e){
            cryptutil.saveParam(function(r){}, "", RetVal);
        }
    }
}

// 서버로부터 가져온 파일목록 나타내기 - 개인판서함
function reciveGetList2(data) {
    return data;
}

// 서버로부터 가져온 파일목록 나타내기
function reciveGetList(data) {
    restoreExplorerForm();
    
    var result = data.substring((data.indexOf("\r\n"))+2);
    if ( "Success" != result.substring(0, 7) )  {
        if(result == "etwork Error"){
            navigator.notification.alert("네트워크 연결 상태를 확인 후\n이용해 주세요.", function(){}, "", "확인");
        } else {
            navigator.notification.alert(result, function(){}, "", "확인");
        }
    }
    
    contents = result.substring((result.indexOf("\r\n"))+2);
    list = contents.substring(contents.indexOf("\r\n")+2).split("\r\n");
    //    check(list);
    var folderInfo = "", folderCount = 0, tempList = list, list = new Array();
    for ( var index = 0; index < tempList.length; index++ ) {
        folderInfo = tempList[index].split("\t");
        if ( (parseInt(folderInfo[3]) & 0x20) != 0 ) {
            list.unshift(tempList[index]);
            folderCount++;
        } else {
            list.push(tempList[index]);
        }
    }
    
    qSort("getList", list, 0, folderCount - 1);
    
    controlShowPath();
    
    // 경로 선택에 추가
    var path = "";
    path = GetsessionStorage(tmpOwner) + tmpUserPath;
    var choicePath = path.split("/");
    $('#NetID_choiceFolder option').remove();
    for ( var index = 0; index < choicePath.length; index++ ) {
        if ( choicePath[index] != "" ) {
            if ( index == choicePath.length - 1 )   $('#NetID_choiceFolder').append("<option value="+(choicePath.length-1-index)+" label=\""+choicePath[index]+"\" selected>"+choicePath[index]+"</option>");
            else                                   $('#NetID_choiceFolder').append("<option value="+(choicePath.length-1-index)+" label=\""+choicePath[index]+"\">"+choicePath[index]+"</option>");
        }
    }
    
    // 아무것도 존재하지 않을 시 label 표시
    if ( list.length < 2 ) {
        $('#explorer_lang_server_notExist').css('display', 'inline');
        $('#explorer_lang_server_notExist').css({'top':($('#NetID_explorerList').height() - $('#explorer_lang_server_notExist').height()) / 2 + 'px', 'left':($('#NetID_explorerList').width() - $('#explorer_lang_server_notExist').width()) / 2 + 'px'});
    }
    else
    {
        $('#explorer_lang_server_notExist').css('display', 'none');
    }
    
    File = 0x20;
    OrgFolder = 0x00000100;
    /* 좌측 트리구조 제어 */
    var treeTarget = $("#" + removeSpecialChar(tmpTreeID));
    $(".tree-selected").removeClass("tree-selected");   // 해당 폴더 외 폴더목록 선택효과 제거
    if ( treeTarget.hasClass("tree-folder") ) treeTarget.addClass("tree-selected"); // 해당 폴더 선택효과 적용
    treeTarget.next("div.tree-deeper").remove();    // 해당 폴더 기존 하위폴더목록 제거
    if ( treeTarget.hasClass("tree-close") )    treeTarget.removeClass("tree-close").addClass("tree-open"); // 해당 폴더 열기효과 적용
    treeTarget.after("<div class='tree-deeper'></div>");    // 하위폴더 담을 DOM 생성
    treeTarget = treeTarget.next("div.tree-deeper");    // 대상을 해당 폴더가 아닌, 하위폴더를 담을 DOM 선택

    $(".list").remove();
    $(".contents-list").scrollTop();
    //    if ( list[0] == "" ) {
    if ( data.split("\r\n").length > 3 ) {
    if(tmpDiskType == "OrgCoworkShare") {
        if(tmpShareUser == "" && tmpSharePath == "") {
            for(i=0; i< list.length ; i++) {
                list_info = list[i].split("\t");
                tmpOwner = list_info[6];
                tmpFileServer = list_info[8];
                tmpPartition = list_info[9];
                tmpShareUser = list_info[7];
                
                if ( (parseInt(list_info[3]) & File) != 0 && (parseInt(list_info[3]) & OrgFolder) == 0 ) {
                    //var treeid = tmpTreeID+'/'+i;
                    var treeid = changeSpecialChar(tmpTreeID + '/' + list_info[0]);
                    var folderModDate = list_info[4].substring(0, 10);
                    var folderInfo = list_info[4].substring(11, 16);
                    var folderPath = tmpUserPath + list_info[0];
                    var fileNameParameter = list_info[0].indexOf('\'') > -1?   list_info[0].replace(/\'/gi, "NetID_apostrophe") : list_info[0];
                    var tmpUserPathParameter = tmpUserPath.indexOf('\'') > -1?   tmpUserPath.replace(/\'/gi, "NetID_apostrophe") : tmpUserPath;
                    var fID = tmpUserPath == "/"?   tmpUserPath + list_info[0] : tmpUserPath + "/" + list_info[0];
                    var className = "list list-folder";
                    if ( GetlocalStorage("fileShowInfo") == "show" )    className += " showInfo";
                    
                    treeTarget.append("<div id='" + treeid + "' class='tree-folder tree-close' onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+list_info[6]+"', '"+list_info[8]+"', '"+list_info[9]+"', '"+tmpStartPath+"', '"+tmpUserPathParameter+"', '"+tmpDiskType+"', '"+list_info[7]+"', '"+tmpSharePath+"')\"><label class='imgLabel' onclick=\"treeManager('folder','" + treeid + "', '"+fileNameParameter+"', '"+list_info[6]+"', '"+list_info[8]+"', '"+list_info[9]+"', '"+tmpStartPath+"', '"+tmpUserPathParameter+"', '"+tmpDiskType+"', '"+list_info[7]+"', '"+tmpSharePath+"')\"></label><label class='imgLabel'></label><label><label>" + list_info[0] + "</label><span></span></label></div>");
                    $(".contents-list").append("<div data-filename='" + list_info[0] + "' data-filedate='" + list_info[4] + "' class='" + className + "' ontouchstart='touchStart(this)' ontouchend='touchEnd(this)' ontouchmove='touchEnd(this)'><img src='images/file_icon/flo.png' onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+list_info[6]+"', '"+list_info[8]+"', '"+list_info[9]+"', '"+tmpStartPath+"', '"+tmpUserPathParameter+"', '"+tmpDiskType+"', '"+list_info[7]+"', '"+tmpSharePath+"')\"><label class='openedMenu' onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+list_info[6]+"', '"+list_info[8]+"', '"+list_info[9]+"', '"+tmpStartPath+"', '"+tmpUserPathParameter+"', '"+tmpDiskType+"', '"+list_info[7]+"', '"+tmpSharePath+"')\">" + list_info[0] + "</label><label onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+list_info[6]+"', '"+list_info[8]+"', '"+list_info[9]+"', '"+tmpStartPath+"', '"+tmpUserPathParameter+"', '"+tmpDiskType+"', '"+list_info[7]+"', '"+tmpSharePath+"')\"><p>" + folderModDate + "</p><p>" + folderInfo + "</p></label><img id='" + fID + "' class='list-BM-unchecked' onclick=\"BMAppendDialogManager('open', 'folder', '" + treeid + "', '" + folderPath + "')\"></div>");
                }
            }
            
            for(i=0; i< list.length ; i++) {
                list_info = list[i].split("\t");
                
                if((parseInt(list_info[3]) & File) == 0 && ""!=list_info[0]) {
                    if ( list_info[0].substring(0, 2) == "~$" ) continue;
                    var xfile = list_info[0].substring(list_info[0].lastIndexOf(".") + 1);
                    xfile = xfile.toLowerCase();
                    xfile = get_fileicon(xfile);
                    xfileimg = "img/icon/" + xfile + ".png";
                    var fileModDate = list_info[4].substring(0, 10);
                    var fileInfo = list_info[4].substring(11, 16) + "&nbsp;&nbsp;" + size_format(list_info[1]);
                    var fID = tmpUserPath == "/"?   tmpUserPath + list_info[0] : tmpUserPath + "/" + list_info[0];
                    var className = "list list-file";
                    if ( GetlocalStorage("fileShowInfo") == "show" )    className += " showInfo";
                    
                                                                                                     var path = paraDiskType + tmpUserPath + ("/" == tmpUserPath? "" : "/") + list_info[0];
                                                                                                     var selectClassName = ( "select" == nowMode && mSelectedFiles.hasOwnProperty(path) )? "list-checked" : "list-unchecked";
                                                                                                     
                    $(".contents-list").append("<div data-size='" + list_info[1] + "'data-filename='" + list_info[0] + "' data-filedate='" + list_info[4] + "' data-permission='" + list_info[2] + "' class='" + className + "' ontouchstart='touchStart(this)' ontouchend='touchEnd(this)' ontouchmove='touchMove(this)'><img src='" + xfileimg + "' onclick=\"getFile('" + fileNameParameter + "', '" + list_info[1] + "', '" + list_info[2] + "')\"><label class='openedMenu' onclick=\"getFile('" + fileNameParameter + "', '" + list_info[1] + "', '" + list_info[2] + "')\">" + list_info[0] + "</label><label onclick=\"getFile('" + fileNameParameter + "', '" + list_info[1] + "', '" + list_info[2] + "', '" + list_info[2] + "')\"><p>" + fileModDate + "</p><p>" + fileInfo + "</p></label><img id='" + fID + "' class='list-BM-unchecked' onclick=\"BMAppendDialogManager('open', 'file', '" + fileNameParameter + "', '" + list_info[1] + "', '" + list_info[2] + "')\"><img class='" + selectClassName + "' onclick=\"addSelectedFile(this)\"></div>");
                }
            }
        } else {
            for(i=0; i< list.length ; i++) {
                list_info = list[i].split("\t");
                if(list_info[5] != null)
                    tmpSharePath = list_info[5];
                if((parseInt(list_info[3]) & File) != 0 && (parseInt(list_info[3]) & OrgFolder) == 0) {
                    //var treeid = tmpTreeID+'/'+i;
                    var treeid = changeSpecialChar(tmpTreeID + '/' + list_info[0]);
                    var folderModDate = list_info[4].substring(0, 10);
                    var folderInfo = list_info[4].substring(11, 16);
                    var folderPath = tmpUserPath + list_info[0];
                    var fileNameParameter = list_info[0].indexOf('\'') > -1?   list_info[0].replace(/\'/gi, "NetID_apostrophe") : list_info[0];
                    var tmpUserPathParameter = tmpUserPath.indexOf('\'') > -1?   tmpUserPath.replace(/\'/gi, "NetID_apostrophe") : tmpUserPath;
                    var fID = tmpUserPath == "/"?   tmpUserPath + list_info[0] : tmpUserPath + "/" + list_info[0];
                    var className = "list list-folder";
                    if ( GetlocalStorage("fileShowInfo") == "show" )    className += " showInfo";
                    
                    treeTarget.append("<div id='" + treeid + "' class='tree-folder tree-close' onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+tmpOwner+"', '"+tmpFileServer+"', '"+tmpPartition+"', '"+tmpStartPath+"', '"+tmpUserPathParameter+"', '"+tmpDiskType+"', '"+tmpShareUser+"', '"+tmpSharePath+"')\"><label class='imgLabel' onclick=\"treeManager('folder','" + treeid + "', '"+fileNameParameter+"', '"+tmpOwner+"', '"+tmpFileServer+"', '"+tmpPartition+"', '"+tmpStartPath+"', '"+tmpUserPathParameter+"', '"+tmpDiskType+"', '"+tmpShareUser+"', '"+tmpSharePath+"')\"></label><label class='imgLabel'></label><label><label>" + list_info[0] + "</label><span></span></label></div>");
                    $(".contents-list").append("<div data-filename='" + list_info[0] + "' data-filedate='" + list_info[4] + "' class='" + className + "' ontouchstart='touchStart(this)' ontouchend='touchEnd(this)' ontouchmove='touchEnd(this)'><img src='images/file_icon/flo.png' onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+tmpOwner+"', '"+tmpFileServer+"', '"+tmpPartition+"', '"+tmpStartPath+"', '"+tmpUserPathParameter+"', '"+tmpDiskType+"', '"+tmpShareUser+"', '"+tmpSharePath+"')\"><label class='openedMenu' onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+tmpOwner+"', '"+tmpFileServer+"', '"+tmpPartition+"', '"+tmpStartPath+"', '"+tmpUserPathParameter+"', '"+tmpDiskType+"', '"+tmpShareUser+"', '"+tmpSharePath+"')\">" + list_info[0] + "</label><label onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+tmpOwner+"', '"+tmpFileServer+"', '"+tmpPartition+"', '"+tmpStartPath+"', '"+tmpUserPathParameter+"', '"+tmpDiskType+"', '"+tmpShareUser+"', '"+tmpSharePath+"')\"><p>" + folderModDate + "</p><p>" + folderInfo + "</p></label><img id='" + fID + "' class='list-BM-unchecked' onclick=\"BMAppendDialogManager('open', 'folder', '" + treeid + "', '" + folderPath + "')\"></div>");
                }
            }
            
            for(i=0; i< list.length ; i++) {
                list_info = list[i].split("\t");
                
                if((parseInt(list_info[3]) & File) == 0 && ""!=list_info[0]) {
                    if ( list_info[0].substring(0, 2) == "~$" ) continue;
                    var xfile = list_info[0].substring(list_info[0].lastIndexOf(".") + 1);
                    xfile = xfile.toLowerCase();
                    xfile = get_fileicon(xfile);
                    xfileimg = "img/icon/" + xfile + ".png";
                    var fileModDate = list_info[4].substring(0, 10);
                    var fileInfo = list_info[4].substring(11, 16) + "&nbsp;&nbsp;" + size_format(list_info[1]);
                    var fID = tmpUserPath == "/"?   tmpUserPath + list_info[0] : tmpUserPath + "/" + list_info[0];
                    var className = "list list-file";
                    if ( GetlocalStorage("fileShowInfo") == "show" )    className += " showInfo";
                    
                                                                                                     var path = paraDiskType + tmpUserPath + ("/" == tmpUserPath? "" : "/") + list_info[0];
                                                                                                     var selectClassName = ( "select" == nowMode && mSelectedFiles.hasOwnProperty(path) )? "list-checked" : "list-unchecked";
                                                                                                     
                    $(".contents-list").append("<div data-size='" + list_info[1] + "'data-filename='" + list_info[0] + "' data-filedate='" + list_info[4] + "' data-permission='" + list_info[2] + "' class='" + className + "' ontouchstart='touchStart(this)' ontouchend='touchEnd(this)' ontouchmove='touchMove(this)'><img src='" + xfileimg + "' onclick=\"getFile('" + fileNameParameter + "', '" + list_info[1] + "', '" + list_info[2] + "')\"><label class='openedMenu' onclick=\"getFile('" + fileNameParameter + "', '" + list_info[1] + "', '" + list_info[2] + "')\">" + list_info[0] + "</label><label onclick=\"getFile('" + fileNameParameter + "', '" + list_info[1] + "', '" + list_info[2] + "')\"><p>" + fileModDate + "</p><p>" + fileInfo + "</p></label><img id='" + fID + "' class='list-BM-unchecked' onclick=\"BMAppendDialogManager('open', 'file', '" + fileNameParameter + "', '" + list_info[1] + "', '" + list_info[2] + "')\"><img class='" + selectClassName + "' onclick=\"addSelectedFile(this)\"></div>");
                }
            }
        }
    } else {
        for(i=0; i< list.length ; i++) {
            list_info = list[i].split("\t");
            
            if ( (parseInt(list_info[3]) & File) != 0 && (parseInt(list_info[3]) & OrgFolder) == 0 ) {
                //var treeid = tmpTreeID+'/'+i;
                var treeid = changeSpecialChar(tmpTreeID + '/' + list_info[0]);
                var folderModDate = list_info[4].substring(0, 10);
                var folderInfo = list_info[4].substring(11, 16);
                var folderPath = tmpUserPath == "/"?    tmpUserPath + list_info[0] : tmpUserPath + "/" + list_info[0];
                var fileNameParameter = list_info[0].indexOf('\'') > -1?   list_info[0].replace(/\'/gi, "NetID_apostrophe") : list_info[0];
                var tmpUserPathParameter = tmpUserPath.indexOf('\'') > -1?   tmpUserPath.replace(/\'/gi, "NetID_apostrophe") : tmpUserPath;
                if ( list_info[0] == "RECYCLER" )   continue;
                var fID = tmpUserPath == "/"?   tmpUserPath + list_info[0] : tmpUserPath + "/" + list_info[0];
                var className = "list list-folder";
                if ( GetlocalStorage("fileShowInfo") == "show" )    className += " showInfo";
                
                //                    treeTarget.append("<div id='" + treeid + "' class='tree-folder tree-close'><label class='imgLabel' onclick=\"javascript:treeManager('" + treeid + "', '"+fileNameParameter+"', '"+tmpOwner+"', '"+tmpFileServer+"', '"+tmpPartition+"', '"+tmpStartPath+"', '"+tmpUserPathParameter+"', '"+paraDiskType+"', '"+tmpShareUser+"', '"+tmpSharePath+"')\"></label><label class='imgLabel' onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+tmpOwner+"', '"+tmpFileServer+"', '"+tmpPartition+"', '"+tmpStartPath+"', '"+tmpUserPathParameter+"', '"+paraDiskType+"', '"+tmpShareUser+"', '"+tmpSharePath+"')\"></label><label><label onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+tmpOwner+"', '"+tmpFileServer+"', '"+tmpPartition+"', '"+tmpStartPath+"', '"+tmpUserPathParameter+"', '"+paraDiskType+"', '"+tmpShareUser+"', '"+tmpSharePath+"')\">" + list_info[0] + "</label><span></span></label></div>");
                treeTarget.append("<div id='" + treeid + "' class='tree-folder tree-close' onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+tmpOwner+"', '"+tmpFileServer+"', '"+tmpPartition+"', '"+tmpStartPath+"', '"+tmpUserPathParameter+"', '"+paraDiskType+"', '"+tmpShareUser+"', '"+tmpSharePath+"')\"><label class='imgLabel' onclick=\"treeManager('folder','" + treeid + "', '"+fileNameParameter+"', '"+tmpOwner+"', '"+tmpFileServer+"', '"+tmpPartition+"', '"+tmpStartPath+"', '"+tmpUserPathParameter+"', '"+paraDiskType+"', '"+tmpShareUser+"', '"+tmpSharePath+"')\"></label><label class='imgLabel'></label><label><label>" + list_info[0] + "</label><span></span></label></div>");
                $(".contents-list").append("<div data-filename='" + list_info[0] + "' data-filedate='" + list_info[4] + "' class='" + className + "' ontouchstart='touchStart(this)' ontouchend='touchEnd(this)' ontouchmove='touchEnd(this)'><img src='images/file_icon/flo.png' onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+tmpOwner+"', '"+tmpFileServer+"', '"+tmpPartition+"', '"+tmpStartPath+"', '"+tmpUserPathParameter+"', '"+paraDiskType+"', '"+tmpShareUser+"', '"+tmpSharePath+"')\"><label class='openedMenu' onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+tmpOwner+"', '"+tmpFileServer+"', '"+tmpPartition+"', '"+tmpStartPath+"', '"+tmpUserPathParameter+"', '"+paraDiskType+"', '"+tmpShareUser+"', '"+tmpSharePath+"')\">" + list_info[0] + "</label><label onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+tmpOwner+"', '"+tmpFileServer+"', '"+tmpPartition+"', '"+tmpStartPath+"', '"+tmpUserPathParameter+"', '"+paraDiskType+"', '"+tmpShareUser+"', '"+tmpSharePath+"')\"><p>" + folderModDate + "</p><p>" + folderInfo + "</p></label><img id='" + fID + "' class='list-BM-unchecked' onclick=\"BMAppendDialogManager('open', 'folder', '" + treeid + "', '" + folderPath + "')\"></div>");
                if(list_info[0] == "개인판서함"){
                    savetreeid = treeid;
                    savefoldername = fileNameParameter;
                    saveowner = tmpOwner;
                    saveserver = tmpFileServer;
                    savepartition = tmpPartition;
                    savestartpath = tmpStartPath;
                    saveuserpath = tmpUserPathParameter;
                    savedisktype = paraDiskType;
                    saveshareuser = tmpShareUser;
                    savesharepath = tmpSharePath;
                }
            }
        }
        
        for(i = 0; i < list.length; i++) {
            list_info = list[i].split("\t");
            
            if((parseInt(list_info[3]) & File) == 0 && list_info[0] != "") {
                if ( list_info[0].substring(0, 2) == "~$" ) continue;
                var xfile = list_info[0].substring(list_info[0].lastIndexOf(".") + 1);
                xfile = xfile.toLowerCase();
                xfile = get_fileicon(xfile);
                xfileimg = "images/file_icon/" + xfile + ".png";
                var fileModDate = list_info[4].substring(0, 10);
                var fileInfo = list_info[4].substring(11, 16) + "&nbsp;&nbsp;" + size_format(list_info[1]);
                var fileNameParameter = list_info[0].indexOf('\'') > -1?   list_info[0].replace(/\'/gi, "NetID_apostrophe") : list_info[0];
                var fID = tmpUserPath == "/"?   tmpUserPath + list_info[0] : tmpUserPath + "/" + list_info[0];
                var className = "list list-file";
                if ( GetlocalStorage("fileShowInfo") == "show" )    className += " showInfo";
                                                                                                var path = paraDiskType + tmpUserPath + ("/" == tmpUserPath? "" : "/") + list_info[0];
                                                                                                var selectClassName = ( "select" == nowMode && mSelectedFiles.hasOwnProperty(path) )? "list-checked" : "list-unchecked";
                                                                                                
                $(".contents-list").append("<div data-size='" + list_info[1] + "'data-filename='" + list_info[0] + "' data-filedate='" + list_info[4] + "' data-permission='" + list_info[2] + "' class='" + className + "' ontouchstart='touchStart(this)' ontouchend='touchEnd(this)' ontouchmove='touchMove(this)'><img src='" + xfileimg + "' onclick=\"getFile('" + fileNameParameter + "', '" + list_info[1] + "', '" + list_info[2] + "')\"><label class='openedMenu' onclick=\"getFile('" + fileNameParameter + "', '" + list_info[1] + "', '" + list_info[2] + "')\">" + list_info[0] + "</label><label onclick=\"getFile('" + fileNameParameter + "', '" + list_info[1] + "', '" + list_info[2] + "')\"><p>" + fileModDate + "</p><p>" + fileInfo + "</p></label><img id='" + fID + "' class='list-BM-unchecked' onclick=\"BMAppendDialogManager('open', 'file', '" + fileNameParameter + "', '" + list_info[1] + "', '" + list_info[2] + "')\"><img class='" + selectClassName + "' onclick=\"addSelectedFile(this)\"></div>");
            }
        }
    }
                                                                                                }
    //    }
    
    if ( nowMode == "select" ) selectMode(true);
                                                                                                
    treeTarget.slideDown(250, function() {
        if ( $(".tree-folder").length > 0 ) {
            var maxWidth = $("nav > div:nth-child(2)").width();
            var scrollWidth = $("nav > div:nth-child(2)").prop("scrollWidth");
            $(".tree-folder").each(function() { $(this).width(scrollWidth + (maxWidth - $(this).width()) + $(this).offset().left); });
            treeTarget.find("div > label:nth-child(1)").click(function(evt){evt.stopPropagation();});
        }
                         treeScrollAutoMove(treeTarget);
    });
    checkBMExist();
    
    if ( GetlocalStorage("Sort") == "LtH")          sort("LtH");
    else if ( GetlocalStorage("Sort") == "HtL" )   sort("HtL");
    else if ( GetlocalStorage("Sort") == "new" )   sort("new");
    else if ( GetlocalStorage("Sort") == "old" )   sort("old");
    else                                            sort_default();
    
    if ( treeTarget.length < 1 )    treeManager("folder", tmpTreeID, tmpFolderName, tmpOwner, tmpFileServer, tmpPartition, tmpStartPath, tmpUserPath.substring(0, tmpUserPath.lastIndexOf('/')), paraDiskType, tmpShareUser, tmpShareOwner);
    if ( $(".contents-search input").val() != "" )  searchFile();
}

function treeScrollAutoMove(treeTarget) {
                                                                                                var treeExplorer = $("nav > div:nth-child(2)");
                                                                                                var treeTargetPositionTop = treeTarget.position().top;
                                                                                                var treeTargetPositionBottom = treeTarget.parent().height() - treeTarget.position().top - treeTarget.height();
                                                                                                var treeTargetParent = treeTarget.parent();
                                                                                                for ( ; treeTargetParent.hasClass("tree-deeper"); treeTargetParent = treeTargetParent.parent() ) {
                                                                                                    treeTargetPositionTop += treeTargetParent.position().top;
                                                                                                    treeTargetPositionBottom += treeTargetParent.parent().height() - treeTargetParent.position().top - treeTargetParent.height();
                                                                                                }
                                                                                                
                                                                                                //alert(treeTargetPositionTop + ", " + treeTargetPositionBottom + ", " + treeExplorer.height());
                                                                                                if ( treeTargetPositionBottom < 0 ) {
                                                                                                    var scrollPosition = treeExplorer.scrollTop() + 70 - treeTargetPositionBottom;
                                                                                                    if ( scrollPosition > treeTargetPositionTop )   scrollPosition = treeExplorer.scrollTop() + treeTargetPositionTop - 35;
                                                                                                    treeExplorer.scrollTop(scrollPosition);
                                                                                                }
                                                                                                // else if ( treeTargetPositionBottom > treeExplorer.height() )
                                                                                                else if ( treeTargetPositionTop < 35 )
                                                                                                {
                                                                                                //alert(treeTargetPositionBottom + ", " + treeExplorer.height());
                                                                                                    var scrollPosition = treeExplorer.scrollTop() + treeTargetPositionTop - 35;
                                                                                                //alert(scrollPosition);
                                                                                                    treeExplorer.scrollTop(scrollPosition);
                                                                                                }
}
                                                                                                
function treeManager(target, treeID, foldername, owner, server, partiton, startpath, userpath, disktype, shareuser, sharepath) {
    var originalTreeID = treeID;
    var originalFolderName = foldername;
    var originalUserPath = userpath;
    var originalDiskType = disktype;
    var treeTarget = $("#" + removeSpecialChar(treeID));
    
    if ( treeID.split('/').length > 3 && treeTarget.length < 1 ) {
        while ( treeTarget.length < 1 ) {
            treeID = treeID.substring(0, treeID.lastIndexOf('/'));
            treeTarget = $("#" + removeSpecialChar(treeID));
        }
        userpath = "/";
        var tempUserPath = treeID.split('/');
        for ( var index = 3; index < tempUserPath.length - 1; index++ ) {
            userpath += userpath.charAt(userpath.length - 1) == "/"?    tempUserPath[index] : "/" + tempUserPath[index];
        }
    }
    foldername = treeID.substring(treeID.lastIndexOf('/') + 1);
    
    //alert(treeID + "\n" + foldername + "\n" + owner + "\n" + server + "\n" + partiton + "\n" + startpath + "\n" + userpath + "\n" + disktype + "\n" + shareuser + "\n" + sharepath);
    if ( treeTarget.hasClass("tree-close") )
    {   // Closed -> Open
        treeTarget.removeClass("tree-close").addClass("tree-open");
    }
    else
    {
        // Opened -> Close
        treeTarget.removeClass("tree-open").addClass("tree-close");
        treeTarget.next("div.tree-deeper").slideUp(300, function(){$(this).remove();});
        return;
    }
    
    treeTarget.after("<div class='tree-deeper'></div>");
    treeTarget = treeTarget.next("div.tree-deeper");
    
    var parentTreeID = treeID;
    if ( disktype != "OrgCoworkShare" ) disktype = "OrgCowork";
    foldername = foldername.indexOf("NetID_apostrophe") > -1?   foldername.replace(/NetID_apostrophe/gi, '\'') : foldername;
    userpath = userpath.indexOf("NetID_apostrophe") > -1?   userpath.replace(/NetID_apostrophe/gi, '\'') : userpath;
    userpath = (userpath + "/" + foldername).replace("//", "/");
    if ( userpath == "/개인문서함" || userpath == "/공유문서함" ) {
        target = "drive";
        userpath = "/";
    }
    
    if ( target == "drive" ) {
        userpath = "/";
        shareuser = "";
        sharepath = "";
        target = "folder";
    }
    
    if(disktype == "OrgCowork") option = " ";
    disktype == "personal"? option = "0x01" : option = "0x00";
    var parameter = userpath + "\t" + tmpSubtree + "\t" + tmpDomainID + "\t" + disktype + "\t" +
    GetsessionStorage("UserID") + "\t" + partiton + "\t" + tmpWebServer + "\t" +
    GetlocalStorage("Platform") + "\t" + option + "\t" + owner + "\t" + shareuser + "\t" +
    sharepath + "\t" + startpath + "\t" + "yes";
                                                                                                
    try{
        CryptUtil = new CryptUtil();
        CryptUtil.call(function(r){
                       var port = GetlocalStorage("port");
                       var server = GetlocalStorage("webserver");
                       var RetArr = r.split("\t");
                       
                       authID = GetlocalStorage("UserID");
                       AuthKey = GetlocalStorage("AuthKey");
                       AuthMac = GetlocalStorage("mac");
                       serviceID = GetlocalStorage("serviceID");
                       
                       var paraData = "Server=" + server +
                       "&Port=" + port +
                       "&Url=" + "/PlusDrive/GetList" +
                       "&CookieData=" + "DomainID="+ RetArr[2] + ";DiskType="+ RetArr[3] + ";User="+ RetArr[4] +
                       ";Partition="+ RetArr[5] + ";WebServer="+ RetArr[6] + ";Agent="+ RetArr[7] +
                       ";Option="+ RetArr[8] + ";Cowork="+ RetArr[9] + ";ShareUser="+ RetArr[10] +
                       ";SharePath="+ RetArr[11] + ";StartPath="+ RetArr[12] + ";RealIP="+ RetArr[14] +
                       "&ParamData=" + "SrcName=" + RetArr[0] + ";Subtree=" + RetArr[1] +";OnlyDir="+ RetArr[13] +"&AccountId="+authID+"&AuthKey="+AuthKey+"&mac="+AuthMac+"&serviceID="+serviceID;
                       
                       request2.onload = function() {
                       if ( request2.readyState == 4 && request2.status == 200 ) {
                       var result = request2.responseText.substring((request2.responseText.indexOf("\r\n"))+2);
                       if ( "Success" != result.substring(0, 7) )  alertMessage(result);
                       var contents = result.substring((result.indexOf("\r\n")) + 2);
                       if ( contents.indexOf("\r\n") < 0 ) return;
                       var list = contents.substring((contents.indexOf("\r\n")) + 2).split("\r\n");
                       qSort("getList", list, 0, list.length - 1);
                       //                       list.sort();
                       
                       treeTarget.children("div").remove();
                       
                       for ( var index = 0; index < list.length; index++ ) {
                       var list_info = list[index].split("\t");
                       if ( list_info[0] == "desktop.ini" ) continue;
                       
                       //                       var treeid = parentTreeID + '/' + index;
                       var treeid = changeSpecialChar(treeID + '/' + list_info[0]);
                       var fileNameParameter = list_info[0].indexOf('\'') > -1?   list_info[0].replace(/\'/gi, "NetID_apostrophe") : list_info[0];
                       var tmpUserPathParameter = userpath.indexOf('\'') > -1?     userpath.replace(/\'/gi, "NetID_apostrophe") : userpath;
                                                                                                    
                       // Is it Share drive?
                       if ( disktype == "OrgCoworkShare" ) {
                       if ( shareuser == "" && tmpSharepath == "" ) {
                       owner = list_info[6];
                       server = list_info[8];
                       partiton = list_info[9];
                       shareuser = list_info[7];
                       if(list_info[0] != "RECYCLER"){
                       treeTarget.append("<div id='" + treeid + "' class='tree-folder tree-close' onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+list_info[6]+"', '"+list_info[8]+"', '"+list_info[9]+"', '"+startpath+"', '"+tmpUserPathParameter+"', '"+disktype+"', '"+list_info[7]+"', '"+tmpSharePath+"')\"><label class='imgLabel' onclick=\"treeManager('folder','" + treeid + "', '"+fileNameParameter+"', '"+list_info[6]+"', '"+list_info[8]+"', '"+list_info[9]+"', '"+startpath+"', '"+tmpUserPathParameter+"', '"+disktype+"', '"+list_info[7]+"', '"+tmpSharePath+"')\"></label><label class='imgLabel'></label><label><label>" + list_info[0] + "</label><span></span></label></div>");
                       }
                       }
                       else
                       {
                       if ( list_info[5] != null ) tmpSharePath = list_info[5];
                       if(list_info[0] != "RECYCLER"){
                       treeTarget.append("<div id='" + treeid + "' class='tree-folder tree-close' onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+owner+"', '"+server+"', '"+partiton+"', '"+startpath+"', '"+tmpUserPathParameter+"', '"+disktype+"', '"+shareuser+"', '"+tmpSharePath+"')\"><label class='imgLabel' onclick=\"treeManager('folder','" + treeid + "', '"+fileNameParameter+"', '"+owner+"', '"+server+"', '"+partiton+"', '"+startpath+"', '"+tmpUserPathParameter+"', '"+disktype+"', '"+shareuser+"', '"+tmpSharePath+"')\"></label><label class='imgLabel'></label><label><label>" + list_info[0] + "</label><span></span></label></div>");
                       }
                       }
                       }
                       else
                       {
                       if(list_info[0] != "RECYCLER"){
                       treeTarget.append("<div id='" + treeid + "' class='tree-folder tree-close' onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+owner+"', '"+server+"', '"+partiton+"', '"+startpath+"', '"+tmpUserPathParameter+"', '"+originalDiskType+"', '"+shareuser+"', '"+tmpSharePath+"')\"><label class='imgLabel' onclick=\"treeManager('folder','" + treeid + "', '"+fileNameParameter+"', '"+owner+"', '"+server+"', '"+partiton+"', '"+startpath+"', '"+tmpUserPathParameter+"', '"+originalDiskType+"', '"+shareuser+"', '"+tmpSharePath+"')\"></label><label class='imgLabel'></label><label><label>" + list_info[0] + "</label><span></span></label></div>");
                       }
                       }
                       
                       // 현재 항목 재선택
                       var treeUserPath = userpath == "/"? userpath + list_info[0] : userpath + "/" + list_info[0];
                       if ( tmpUserPath == treeUserPath )  treeTarget.children("div:last-child").addClass("tree-selected");
                       }
                       treeTarget.slideDown(250, function() {
                           var maxWidth = $("nav > div:nth-child(2)").width();
                           var scrollWidth = $("nav > div:nth-child(2)").prop("scrollWidth");
                           $(".tree-folder").each(function() { $(this).width(scrollWidth + (maxWidth - $(this).width()) + $(this).offset().left); });
                                            treeScrollAutoMove(treeTarget);
                           treeTarget.find("div > label:nth-child(1)").click(function(evt){evt.stopPropagation();});
                       });
                       if ( $("#" + removeSpecialChar(originalTreeID)).length < 1 || $("#" + removeSpecialChar(originalTreeID)).hasClass("tree-close") )    treeManager("folder", originalTreeID, originalFolderName, owner, server, partiton, startpath, originalUserPath, originalDiskType, shareuser, sharepath);
                       }
                       
                       }
                       
                       AjaxRequest2(GetlocalStorage("protocol"), port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);}, function(){}, parameter, GetlocalStorage("SiteID"));
        
    }catch(e){
        CryptUtil.call(function(r){
                       var port = GetlocalStorage("port");
                       var server = GetlocalStorage("webserver");
                       var RetArr = r.split("\t");
                       
                       authID = GetlocalStorage("UserID");
                       AuthKey = GetlocalStorage("AuthKey");
                       AuthMac = GetlocalStorage("mac");
                       serviceID = GetlocalStorage("serviceID");
                       
                       var paraData = "Server=" + server + "&Port=" + port + "&Url=" + "/PlusDrive/GetList" + "&CookieData=" + "DomainID="+ RetArr[2] + ";DiskType="+ RetArr[3] + ";User="+ RetArr[4] + ";Partition="+ RetArr[5] + ";WebServer="+ RetArr[6] + ";Agent="+ RetArr[7] + ";Option="+ RetArr[8] + ";Cowork="+ RetArr[9] + ";ShareUser="+ RetArr[10] + ";SharePath="+ RetArr[11] + ";StartPath="+ RetArr[12] + ";RealIP="+ RetArr[14] + "&ParamData=" + "SrcName=" + RetArr[0] + ";Subtree=" + RetArr[1] +";OnlyDir="+ RetArr[13] +"&AccountId="+authID+"&AuthKey="+AuthKey+"&mac="+AuthMac+"&serviceID="+serviceID;
                       
                       request2.onload = function() {
                       if ( request2.readyState == 4 && request2.status == 200 ) {
                       var result = request2.responseText.substring((request2.responseText.indexOf("\r\n"))+2);
                       if ( "Success" != result.substring(0, 7) )  alertMessage(result);
                       var contents = result.substring((result.indexOf("\r\n")) + 2);
                       if ( contents.indexOf("\r\n") < 0 ) return;
                       var list = contents.substring((contents.indexOf("\r\n")) + 2).split("\r\n");
                       qSort("getList", list, 0, list.length - 1);
                       //                       list.sort();
                       
                       treeTarget.children("div").remove();
                       
                       for ( var index = 0; index < list.length; index++ ) {
                       var list_info = list[index].split("\t");
                       if ( list_info[0] == "desktop.ini" ) continue;
                       
                       //                       var treeid = parentTreeID + '/' + index;
                       var treeid = changeSpecialChar(treeID + '/' + list_info[0]);
                       var fileNameParameter = list_info[0].indexOf('\'') > -1?   list_info[0].replace(/\'/gi, "NetID_apostrophe") : list_info[0];
                       var tmpUserPathParameter = userpath.indexOf('\'') > -1?     userpath.replace(/\'/gi, "NetID_apostrophe") : userpath;

                       // Is it Share drive?
                       if ( disktype == "OrgCoworkShare" ) {
                       if ( shareuser == "" && tmpSharepath == "" ) {
                       owner = list_info[6];
                       server = list_info[8];
                       partiton = list_info[9];
                       shareuser = list_info[7];
                       if(list_info[0] != "RECYCLER"){
                       treeTarget.append("<div id='" + treeid + "' class='tree-folder tree-close' onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+list_info[6]+"', '"+list_info[8]+"', '"+list_info[9]+"', '"+startpath+"', '"+tmpUserPathParameter+"', '"+disktype+"', '"+list_info[7]+"', '"+tmpSharePath+"')\"><label class='imgLabel' onclick=\"treeManager('folder','" + treeid + "', '"+fileNameParameter+"', '"+list_info[6]+"', '"+list_info[8]+"', '"+list_info[9]+"', '"+startpath+"', '"+tmpUserPathParameter+"', '"+disktype+"', '"+list_info[7]+"', '"+tmpSharePath+"')\"></label><label class='imgLabel'></label><label><label>" + list_info[0] + "</label><span></span></label></div>");
                       }
                       }
                       else
                       {
                       if ( list_info[5] != null ) tmpSharePath = list_info[5];
                       if(list_info[0] != "RECYCLER"){
                       treeTarget.append("<div id='" + treeid + "' class='tree-folder tree-close' onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+owner+"', '"+server+"', '"+partiton+"', '"+startpath+"', '"+tmpUserPathParameter+"', '"+disktype+"', '"+shareuser+"', '"+tmpSharePath+"')\"><label class='imgLabel' onclick=\"treeManager('folder','" + treeid + "', '"+fileNameParameter+"', '"+owner+"', '"+server+"', '"+partiton+"', '"+startpath+"', '"+tmpUserPathParameter+"', '"+disktype+"', '"+shareuser+"', '"+tmpSharePath+"')\"></label><label class='imgLabel'></label><label><label>" + list_info[0] + "</label><span></span></label></div>");
                       }
                       }
                       }
                       else
                       {
                       if(list_info[0] != "RECYCLER"){
                       //                       treeTarget.append("<div id='" + treeid + "' class='tree-folder tree-close'><label class='imgLabel' onclick=\"javascript:treeManager('" + treeid + "', '"+fileNameParameter+"', '"+owner+"', '"+server+"', '"+partiton+"', '"+startpath+"', '"+tmpUserPathParameter+"', '"+originalDiskType+"', '"+shareuser+"', '"+tmpSharePath+"')\"></label><label class='imgLabel' onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+owner+"', '"+server+"', '"+partiton+"', '"+startpath+"', '"+tmpUserPathParameter+"', '"+originalDiskType+"', '"+shareuser+"', '"+tmpSharePath+"')\"></label><label><label onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+owner+"', '"+server+"', '"+partiton+"', '"+startpath+"', '"+tmpUserPathParameter+"', '"+originalDiskType+"', '"+shareuser+"', '"+tmpSharePath+"')\">" + list_info[0] + "</label><span></span></label></div>");
                       treeTarget.append("<div id='" + treeid + "' class='tree-folder tree-close' onclick=\"downFolder('" + treeid + "', '"+fileNameParameter+"', '"+owner+"', '"+server+"', '"+partiton+"', '"+startpath+"', '"+tmpUserPathParameter+"', '"+originalDiskType+"', '"+shareuser+"', '"+tmpSharePath+"')\"><label class='imgLabel' onclick=\"treeManager('folder','" + treeid + "', '"+fileNameParameter+"', '"+owner+"', '"+server+"', '"+partiton+"', '"+startpath+"', '"+tmpUserPathParameter+"', '"+originalDiskType+"', '"+shareuser+"', '"+tmpSharePath+"')\"></label><label class='imgLabel'></label><label><label>" + list_info[0] + "</label><span></span></label></div>");
                       }
                       }
                       // 현재 항목 재선택
                       var treeUserPath = userpath == "/"? userpath + list_info[0] : userpath + "/" + list_info[0];
                       if ( tmpUserPath == treeUserPath )  treeTarget.children("div:last-child").addClass("tree-selected");
                       }
                       treeTarget.slideDown(250, function() {
                           var maxWidth = $("nav > div:nth-child(2)").width();
                           var scrollWidth = $("nav > div:nth-child(2)").prop("scrollWidth");
                           $(".tree-folder").each(function() { $(this).width(scrollWidth + (maxWidth - $(this).width()) + $(this).offset().left); });
                                            treeScrollAutoMove(treeTarget);
                           treeTarget.find("div > label:nth-child(1)").click(function(evt){evt.stopPropagation();});
                       });
                       if ( $("#" + removeSpecialChar(originalTreeID)).length < 1 || $("#" + removeSpecialChar(originalTreeID)).hasClass("tree-close") )    treeManager("folder", originalTreeID, originalFolderName, owner, server, partiton, startpath, originalUserPath, originalDiskType, shareuser, sharepath);
                       }
                       }
                       AjaxRequest2(GetlocalStorage("protocol"), port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);}, function(){}, parameter, GetlocalStorage("SiteID"));
    }
    //                                                                                                       var pos=treeTarget.offset();
    //                                                                                                       $("nav > div:nth-child(2)").animate({scrollTop:pos.top},'slow');
}


/* 파일 확장자에 따라 파일이미지 결정
 * reciveGetList() -> get_fileicon()
 */
function get_fileicon(xfilename) {
    
    var icon_array = ["ai", "ais", "alz", "arj", "asf", "asp", "avi", "bak","bat", "bmp", "cab", "cda", "com", "css", "doc",
                      "docx", "dwg", "egg", "eml", "eps", "exe", "fla", "flv", "fmp", "fxg", "gif", "gz", "htm", "html", "hwp",
                      "ico", "iff", "ini", "ink", "jas", "jpg", "js", "jsp", "k3g", "kmp", "md", "mid", "mka", "mkv", "mmf",
                      "mov", "mp3", "mp4", "mpeg", "mpg", "ogg", "pak", "pcx", "pdd", "pdf", "pdp", "php", "pif", "png", "ppt",
                      "pptx", "psd", "pxr", "ra", "rar", "raw", "s3m", "skm", "smi", "secure","swf", "tgz", "tif", "tp", "ts", "ttf", "txt",
                      "vob", "wav", "wma", "wmv", "xls", "xlsx", "xml", "zip", "zool"];
    for(k=0 ; k< icon_array.length ; k++) {
        if(xfilename == icon_array[k]) return icon_array[k];
    }
    
    return "etc";
    
}

// String 바이트 구하기
function getByteLength(s) {
    var b, i, c;
    for(b=i=0; c=s.charCodeAt(i++); b+=c>>11?3:c>>7?2:1);
    return b;
}

// Server 새폴더 생성
function newServerFolder(foldername) {
    createFolderPath = (tmpUserPath+"/"+foldername).replace("//", "/");
    Agent = GetlocalStorage("Platform");
    option = "";
    if(paraDiskType == "personal") option = "0x01";
    
    cookie = tmpDomainID + "\t" + tmpDiskType + "\t" + User + "\t" + tmpPartition + "\t" + tmpWebServer + "\t"
    + Agent + "\t" + option + "\t" + tmpOwner + "\t" + tmpShareUser + "\t" + tmpShareOwner + "\t" + tmpStartPath;
    
    parameter = createFolderPath + "\t" + cookie;
    
    try{
        cryptutil = new CryptUtil();
        cryptutil.call(function(r){SuccessCreateDir(r)}, "", parameter, GetlocalStorage("SiteID"));
    }catch(e){
        cryptutil.call(function(r){SuccessCreateDir(r)}, "", parameter, GetlocalStorage("SiteID"));
    }
}

/* Server 새폴더 생성 진행
 * newServerFolder() -> SuccessCreateDir()
 */
function SuccessCreateDir(r) {
    protocol = GetlocalStorage("protocol");
    port = GetlocalStorage("port");
    server = GetlocalStorage("webserver");
    RetArr = new Array();
    RetArr = r.split("\t");
    
    tmpparaData = "SrcName=" + RetArr[0];
    tmpCookie = "DomainID="+ RetArr[1] + ";DiskType="+ RetArr[2] + ";User="+ RetArr[3] + ";Partition="+ RetArr[4]
    + ";WebServer="+ RetArr[5] + ";Agent="+ RetArr[6] + ";Option="+ RetArr[7] + ";Cowork="+ RetArr[8]
    + ";ShareUser="+ RetArr[9] + ";SharePath="+ RetArr[10] + ";StartPath="+ RetArr[11] + ";RealIP="+ RetArr[12];
    
    authID = GetlocalStorage("UserID");
    AuthKey = GetlocalStorage("AuthKey");
    AuthMac = GetlocalStorage("mac");
    serviceID = GetlocalStorage("serviceID");
    
    paraData = "Server=" + tmpFileServer + "&Port=" + port + "&Url=" + "/PlusDrive/CreateDir" + "&CookieData=" + tmpCookie + "&ParamData=" + tmpparaData+"&AccountId="+authID+"&AuthKey="+AuthKey+"&mac="+AuthMac+"&serviceID="+serviceID;
    
    useProxy = GetlocalStorage("useProxy");
    if(useProxy == "true"){
        us = new ProxyConnect();
        us.proxyconn(completeCreateDir, function(){alert('fail');}, protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);
    } else {
        RetVal = AjaxRequest(protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);
        result = RetVal.substring((RetVal.indexOf("\r\n")) + 2);
        
        if("Success" != result.substring(0, 7)){
            if(result != "Auth Fail" && result != "etwork Err"){
                alertMessage(result);
            }
            AM = new AppManager();
            setTimeout(function(){
                       AM.auth_get();
                       AM.finishapp();
                       }, 1000);
        }
        refresh();
        refresh();
    }
}

function completeCreateDir(RetVal){
    result = RetVal.substring((RetVal.indexOf("\r\n")) + 2);
    
    if("Success" != result.substring(0, 7))
        alertMessage(result);
    refresh();
    refresh();
}

// 서버 파일명 변경
function ServerRename(filename) {
    checked_list = $("#explorerList input:checkbox:checked");
    var checkedVal = checked_list[0].value.indexOf("NetID_apostrophe") > -1?   checked_list[0].value.replace(/NetID_apostrophe/gi, '\'') : checked_list[0].value;
    srcName = (tmpUserPath+"/"+checkedVal).replace("//", "/");
    dstName = (tmpUserPath+"/"+filename).replace("//", "/");
    Agent = GetlocalStorage("Platform");
    option = "";
    if(paraDiskType == "personal") option = "0x01";
    
    cookie = tmpDomainID + "\t" + tmpDiskType + "\t" + User + "\t" + tmpPartition + "\t" + tmpWebServer + "\t"
    + Agent + "\t" + option + "\t" + tmpOwner + "\t" + tmpShareUser + "\t" + tmpShareOwner + "\t" + tmpStartPath;
    
    parameter = srcName + "\t" + dstName + "\t" + cookie;
    
    try{
        cryptutil = new CryptUtil();
        cryptutil.call(function(r){SuccessRename(r)}, "", parameter, GetlocalStorage("SiteID"));
    }catch(e){
        cryptutil.call(function(r){SuccessRename(r)}, "", parameter, GetlocalStorage("SiteID"));
    }
}

/* Server 파일명 변경 진행
 * ServerRename() -> SuccessRename()
 */
function SuccessRename(r) {
    protocol = GetlocalStorage("protocol");
    port = GetlocalStorage("port");
    server = GetlocalStorage("webserver");
    RetArr = new Array();
    RetArr = r.split("\t");
    
    tmpparaData = "SrcName=" + RetArr[0] + ";DstName=" + RetArr[1];
    tmpCookie = "DomainID="+ RetArr[2] + ";DiskType="+ RetArr[3] + ";User="+ RetArr[4] + ";Partition="+ RetArr[5]
    + ";WebServer="+ RetArr[6] + ";Agent="+ RetArr[7] + ";Option="+ RetArr[8] + ";Cowork="+ RetArr[9]
    + ";ShareUser="+ RetArr[10] + ";SharePath="+ RetArr[11] + ";StartPath="+ RetArr[12] + ";RealIP="+ RetArr[13];
    
    authID = GetlocalStorage("UserID");
    AuthKey = GetlocalStorage("AuthKey");
    AuthMac = GetlocalStorage("mac");
    serviceID = GetlocalStorage("serviceID");
    
    paraData = "Server="+tmpFileServer+"&Port="+port+"&Url="+"/PlusDrive/RenameFile"+"&CookieData="+tmpCookie+"&ParamData="+tmpparaData+"&AccountId="+authID+"&AuthKey="+AuthKey+"&mac="+AuthMac+"&serviceID="+serviceID;
    
    useProxy = GetlocalStorage("useProxy");
    if(useProxy == "true"){
        us = new ProxyConnect();
        us.proxyconn(completeSuccessRename, function(){alert('fail');}, protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);
    } else {
        RetVal = AjaxRequest(protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);
        result = RetVal.substring((RetVal.indexOf("\r\n"))+2);
        
        if("Success" != result.substring(0, 7)){
            if(result != "Auth Fail" && result != "etwork Err"){
                alertMessage(result);
            }
            AM = new AppManager();
            setTimeout(function(){
                       AM.auth_get();
                       AM.finishapp();
                       }, 1000);
        }
        closeRenameDialog();
        refresh();
        refresh();
    }
}

function completeSuccessRename(RetVal){
    result = RetVal.substring((RetVal.indexOf("\r\n"))+2);
    
    if("Success" != result.substring(0, 7))
        alertMessage(result);
    closeRenameDialog();
    refresh();
    refresh();
}

// Server 파일 삭제 준비
function ServerDeleteFile() {
    option = "";
    if(paraDiskType == "personal") option = "0x01";
    Agent = GetlocalStorage("Platform");
    cookie = tmpDomainID + "\t" + tmpDiskType + "\t" + User + "\t" + tmpPartition + "\t" + tmpWebServer + "\t"
    + Agent + "\t" + option + "\t" + tmpOwner + "\t" + tmpShareUser + "\t" + tmpShareOwner + "\t" + tmpSharePath + "\t" + tmpStartPath;
    
    parameter = "";
    subtree = "yes";
    for(i=0; i < checked_list.length; i++) {
        if(i == 0){
            var checkedVal = checked_list[i].value.indexOf("NetID_apostrophe") > -1?   checked_list[i].value.replace(/NetID_apostrophe/gi, '\'') : checked_list[i].value;
            parameter = (tmpUserPath+"/"+checkedVal).replace("//", "/");
        }
        else {
            var checkedVal = checked_list[i].value.indexOf("NetID_apostrophe") > -1?   checked_list[i].value.replace(/NetID_apostrophe/gi, '\'') : checked_list[i].value;
            parameter = parameter + "\t" + (tmpUserPath+"/"+checkedVal).replace("//", "/");
        }
    }
    parameter = parameter + "\t" + tmpFileServer + "\t" + subtree;
    parameter = parameter + "\t" + cookie;
    try{
        cryptutil = new CryptUtil();
        cryptutil.call(function(r){SuccessDeleteFile(r)}, "", parameter, GetlocalStorage("SiteID"));
    }catch(e){
        cryptutil.call(function(r){SuccessDeleteFile(r)}, "", parameter, GetlocalStorage("SiteID"));
    }
}

/* Server 파일 삭제
 * ServerDeleteFile() -> SuccessDeleteFile()
 */
function SuccessDeleteFile(r) {
    protocol = GetlocalStorage("protocol");
    port = GetlocalStorage("port");
    server = GetlocalStorage("webserver");
    
    RetArr = new Array();
    RetArr = r.split("\t");
    chekecdLength = checked_list.length;
    
    tmpCheckedList = new Array(chekecdLength);
    for(i=0; i<chekecdLength; i++) {
        tmpCheckedList[i] = RetArr[i];
    }
    chekecdLength = chekecdLength-1;
    
    idex = 1;
    tmpParam = ";FileServer=" + RetArr[chekecdLength+(idex++)] + ";Subtree=" + RetArr[chekecdLength+(idex++)];
    
    tmpCookie = "DomainID="+ RetArr[chekecdLength+(idex++)] + ";DiskType="+ RetArr[chekecdLength+(idex++)] + ";User="+ RetArr[chekecdLength+(idex++)] + ";Partition="+ RetArr[chekecdLength+(idex++)]
    + ";WebServer="+ RetArr[chekecdLength+(idex++)] + ";Agent="+ RetArr[chekecdLength+(idex++)] + ";Option="+ RetArr[chekecdLength+(idex++)] + ";Cowork="+ RetArr[chekecdLength+(idex++)]
    + ";ShareUser="+ RetArr[chekecdLength+(idex++)] + ";ShareOwner="+ RetArr[chekecdLength+(idex++)] + ";SharePath="+ RetArr[chekecdLength+(idex++)] + ";StartPath="+ RetArr[chekecdLength+(idex++)] + ";RealIP="+ RetArr[chekecdLength+(idex++)];
    
    DeleteProcess(tmpParam, tmpCookie);
}

/* Server 파일 삭제 진행
 * ServerDeleteFile() -> SuccessDeleteFile() -> DeleteProcess()
 */
function DeleteProcess(tmpParam ,tmpCookie) {
    port = GetlocalStorage("port");
    if(tmpCheckedList.length > 0) {
        tmpparaData = "SrcName=" + tmpCheckedList[0] + tmpParam;
        tmpCheckedList.splice(0, 1);
        
        authID = GetlocalStorage("UserID");
        AuthKey = GetlocalStorage("AuthKey");
        AuthMac = GetlocalStorage("mac");
        serviceID = GetlocalStorage("serviceID");
        
        paraData = "Server=" + tmpFileServer + "&Port=" + port + "&Url=" + "/PlusDrive/DeleteFile" + "&CookieData=" + tmpCookie + "&ParamData=" + tmpparaData+"&AccountId="+authID+"&AuthKey="+AuthKey+"&mac="+AuthMac+"&serviceID="+serviceID;
        
        useProxy = GetlocalStorage("useProxy");
        if(useProxy == "true"){
            us = new ProxyConnect();
            us.proxyconn(completeDeleteProcess, function(){alert('fail');}, protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);
        } else {
            RetVal = AjaxRequest(protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);
            result = RetVal.substring((RetVal.indexOf("\r\n"))+2);
            if("Success" != result.substring(0, 7)){
                if(result != "Auth Fail" && result != "etwork Err"){
                    alertMessage(result);
                }
                AM = new AppManager();
                setTimeout(function(){
                           AM.auth_get();
                           AM.finishapp();
                           }, 1000);
            }
            DeleteProcess(tmpParam, tmpCookie);
        }
        
    } else if(tmpCheckedList.length <= 0){
        refresh();
        showToast(toast_lang_delete);
    }
}


function completeDeleteProcess(RetVal){
    result = RetVal.substring((RetVal.indexOf("\r\n"))+2);
    
    if("Success" != result.substring(0, 7))
        alertMessage(result);
    DeleteProcess(tmpParam, tmpCookie);
    
}
// Server에서 Server로 파일 붙이기 준비
function ServerCopyFile() {
    for(i=0; i < checked_list.length; i++) {
        var checkedVal = checked_list[i].value.indexOf("NetID_apostrophe") > -1?   checked_list[i].value.replace(/NetID_apostrophe/gi, '\'') : checked_list[i].value;
        if(i == 0)	parameter = (saveUserPath+"/"+checkedVal).replace("//", "/");
        else		parameter = parameter + "\t" + (saveUserPath+"/"+checkedVal).replace("//", "/");
        // 작업 원본폴더와 대상폴더가 같은 경우 작업 취소
        samePath= saveUserPath+ checkedVal;
        if(samePath == tmpUserPath) {
            navigator.notification.alert(lang_alert_same_dir, null, 'Server', 'OK');
            return;
        }
    }
    
    parameter = parameter + "\t" + tmpUserPath;
    logintype = GetsessionStorage("LoginType");
    
    dstOption = "0x00";
    if(paraDiskType == "personal" && logintype == "Normal")	dstOption = "0x01";
    else if(paraDiskType == "personal" && logintype == "GuestID")	dstOption = "0x02";
    else if(paraDiskType == "orgcowork" && logintype == "GuestID")	dstOption = "0x04";
    else if(paraDiskType == "homepartition" && logintype == "Normal")	dstOption = "0x08";
    
    if(tmpOwner != saveOwner) {
        parameter = parameter + "\t" + tmpFileServer + "\t" + tmpOwner + "\t" + tmpPartition + "\t" + dstOption + "\t"
        + tmpDiskType + "\t" + tmpStartPath + "\t" + User + "\t" + tmpSharePath + "\t" + tmpShareUser;
    }
    saveParam = "saveParam"+saveOwner;
    
    paraDataArr = GetsessionStorage(saveParam).split("\t");
    saveDiskType = paraDataArr[0];
    saveOrgCode = paraDataArr[1];
    
    savaOption = "0";
    if(saveDiskType == "personal" && logintype == "Normal")				savaOption = "0x01";
    else if(saveDiskType == "personal" && logintype == "GuestID")		savaOption = "0x02";
    else if(saveDiskType == "orgcowork" && logintype == "GuestID")		savaOption = "0x04";
    else if(saveDiskType == "homepartition" && logintype == "Normal")	savaOption = "0x08";
    
    Agent = GetlocalStorage("Platform");
    cookie = tmpDomainID + "\t" + tmpDiskType + "\t" + User + "\t" + savePartition + "\t" + tmpWebServer + "\t"
    + Agent + "\t" + savaOption + "\t" + saveOwner + "\t" + saveShareUser + "\t" + saveShareOwner + "\t" + saveStartPath;
    
    parameter = parameter + "\t" + cookie;
    
    try{
        cryptutil = new CryptUtil();
        cryptutil.call(function(r){SuccessCopyFile(r)}, "", parameter, GetlocalStorage("SiteID"));
    }catch(e){
        cryptutil.call(function(r){SuccessCopyFile(r)}, "", parameter, GetlocalStorage("SiteID"));
    }
    
}

/* Server에서 Server로 파일 붙이기
 * ServerCopyFile() -> SuccessCopyFile()
 */
function SuccessCopyFile(r) {
    protocol = GetlocalStorage("protocol");
    port = GetlocalStorage("port");
    server = GetlocalStorage("webserver");
    
    RetArr = new Array();
    RetArr = r.split("\t");
    
    chekecdLength = checked_list.length;
    tmpCheckedList = new Array(chekecdLength);
    for(i=0; i<chekecdLength; i++) {
        tmpCheckedList[i] = RetArr[i];
    }
    chekecdLength = chekecdLength-1;
    
    idex = 1;
    if(tmpOwner != saveOwner) {
        tmpParam = ";DstName=" + RetArr[chekecdLength+(idex++)] + ";DstFileServer=" + RetArr[chekecdLength+(idex++)] +";DstCowork="+ RetArr[chekecdLength+(idex++)] + ";DstPartition=" + RetArr[chekecdLength+(idex++)] + ";DstOption=" + RetArr[chekecdLength+(idex++)]
        + ";DstDiskType=" + RetArr[chekecdLength+(idex++)] + ";DstStartPath=" + RetArr[chekecdLength+(idex++)] + ";DstUser=" + RetArr[chekecdLength+(idex++)]
        + ";DstSharePath=" + RetArr[chekecdLength+(idex++)] + ";DstShareUser=" + RetArr[chekecdLength+(idex++)];
    } else
        tmpParam = ";DstName=" + RetArr[chekecdLength+(idex++)];
    
    tmpCookie = "DomainID="+ RetArr[chekecdLength+(idex++)] + ";DiskType="+ RetArr[chekecdLength+(idex++)] + ";User="+ RetArr[chekecdLength+(idex++)] + ";Partition="+ RetArr[chekecdLength+(idex++)]
    + ";WebServer="+ RetArr[chekecdLength+(idex++)] + ";Agent="+ RetArr[chekecdLength+(idex++)] + ";Option="+ RetArr[chekecdLength+(idex++)] + ";Cowork="+ RetArr[chekecdLength+(idex++)]
    + ";ShareUser="+ RetArr[chekecdLength+(idex++)] + ";SharePath="+ RetArr[chekecdLength+(idex++)] + ";StartPath="+ RetArr[chekecdLength+(idex++)] + ";RealIP="+ RetArr[chekecdLength+(idex++)];
    
    CopyProcess(tmpParam, tmpCookie);
}

/* 복사작업 수행
 * ServerCopyFile() -> SuccessCopyFile() -> CopyProcess()
 */
function CopyProcess(tmpParam, tmpCookie) {
    port = GetlocalStorage("port");
    if(tmpCheckedList.length > 0) {
        tmpparaData = "SrcName=" + tmpCheckedList[0] + tmpParam;
        tmpCheckedList.splice(0,1);
        
        authID = GetlocalStorage("UserID");
        AuthKey = GetlocalStorage("AuthKey");
        AuthMac = GetlocalStorage("mac");
        serviceID = GetlocalStorage("serviceID");
                                                                                                       
        paraData = "Server="+saveFileServer+"&Port="+port+"&Url="+"/PlusDrive/CopyFile"+"&CookieData="+tmpCookie+"&ParamData="+tmpparaData+"&AccountId="+authID+"&AuthKey="+AuthKey+"&mac="+AuthMac+"&serviceID="+serviceID;
        
        useProxy = GetlocalStorage("useProxy");
        if(useProxy == "true"){
            us = new ProxyConnect();
            
            us.proxyconn(function completeCopyProcess(RetVal){
                         result = RetVal.substring((RetVal.indexOf("\r\n"))+2);
                         
                         if("Success" != result.substring(0, 7)) {
                         if("Invalid Parameter" == result)
                         navigator.notification.alert(lang_alert_path_exists_err, null, 'Explorer', 'OK');
                         else
                         alertMessage(result);
                         }
                         CopyProcess(tmpParam, tmpCookie);
                         }, function(){alert('fail');}, protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);
        } else {
            RetVal = AjaxRequest(protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);
            result = RetVal.substring((RetVal.indexOf("\r\n"))+2);
            
            if("Success" != result.substring(0, 7)) {
                if("Invalid Parameter" == result)
                    navigator.notification.alert(lang_alert_path_exists_err, null, 'Explorer', 'OK');
                else if( result != "Auth Fail" && result != "etwork Err")
                    alertMessage(result);
                AM = new AppManager();
                setTimeout(function(){
                           AM.auth_get();
                           AM.finishapp();
                           }, 1000);
            }
            CopyProcess(tmpParam, tmpCookie);
        }
        
    } else if(tmpCheckedList.length <= 0){
        showToast(toast_lang_copy);
        refresh();
    }
}

// Server에서 Server로 파일 이동 준비
function SeverMoveFile() {
    for(i= 0; i < checked_list.length; i++) {
        var checkedVal = checked_list[i].value.indexOf("NetID_apostrophe") > -1?   checked_list[i].value.replace(/NetID_apostrophe/gi, '\'') : checked_list[i].value;
        if(i == 0)	parameter = (saveUserPath+"/"+checkedVal).replace("//", "/");
        else		parameter = parameter + "\t" + (saveUserPath+"/"+checkedVal).replace("//", "/");
        // 작업 원본폴더와 대상폴더가 같은 경우 작업 취소
        samePath= saveUserPath+ checkedVal;
        if(samePath == tmpUserPath) {
            navigator.notification.alert(lang_alert_same_dir, null, 'Server', 'OK');
            return;
        }
    }
    parameter = parameter + "\t" + tmpUserPath;
    dstOption = "";
    if(paraDiskType == "personal")	dstOption = "0x01";
    else dstOption = "";
    if(tmpOwner != saveOwner) {
        parameter = parameter + "\t" + tmpFileServer + "\t" + tmpOwner + "\t" + tmpPartition + "\t" + dstOption + "\t"
        + tmpDiskType + "\t" + tmpStartPath + "\t" + User + "\t" + tmpSharePath + "\t" + tmpShareUser;
    }
    
    savaOption = "";
    if(paraDiskType == "personal")	savaOption = "0x01";
    else							savaOption = "";
    Agent = GetlocalStorage("Platform");
    cookie = tmpDomainID + "\t" + tmpDiskType + "\t" + User + "\t" + savePartition + "\t" + tmpWebServer + "\t"
    + Agent + "\t" + savaOption + "\t" + saveOwner + "\t" + saveShareUser + "\t" + saveShareOwner + "\t" + saveStartPath;
    
    parameter = parameter + "\t" + cookie;
    
    try{
        cryptutil = new CryptUtil();
        cryptutil.call(function(r){SuccessMoveFile(r)}, "", parameter, GetlocalStorage("SiteID"));
    }catch(e){
        cryptutil.call(function(r){SuccessMoveFile(r)}, "", parameter, GetlocalStorage("SiteID"));
    }
}

/* Server에서 Server로 파일 이동
 * SeverMoveFile() -> SuccessMoveFile()
 */
function SuccessMoveFile(r) {
    protocol = GetlocalStorage("protocol");
    port = GetlocalStorage("port");
    server = GetlocalStorage("webserver");
    
    RetArr = new Array();
    RetArr = r.split("\t");
    
    chekecdLength = checked_list.length;
    tmpCheckedList = new Array(chekecdLength);
    for(i=0; i<chekecdLength; i++) {
        tmpCheckedList[i] = RetArr[i];
    }
    chekecdLength = chekecdLength-1;
    
    idex = 1;
    if(tmpOwner != saveOwner) {
        tmpParam = ";DstName=" + RetArr[chekecdLength+(idex++)] + ";DstFileServer=" + RetArr[chekecdLength+(idex++)] +";DstCowork="+ RetArr[chekecdLength+(idex++)] + ";DstPartition=" + RetArr[chekecdLength+(idex++)] + ";DstOption=" + RetArr[chekecdLength+(idex++)]
        + ";DstDiskType=" + RetArr[chekecdLength+(idex++)] + ";DstStartPath=" + RetArr[chekecdLength+(idex++)] + ";DstUser=" + RetArr[chekecdLength+(idex++)]
        + ";DstSharePath=" + RetArr[chekecdLength+(idex++)] + ";DstShareUser=" + RetArr[chekecdLength+(idex++)];
    } else
        tmpParam = ";DstName=" + RetArr[chekecdLength+(idex++)];
    
    tmpCookie = "DomainID="+ RetArr[chekecdLength+(idex++)] + ";DiskType="+ RetArr[chekecdLength+(idex++)] + ";User="+ RetArr[chekecdLength+(idex++)] + ";Partition="+ RetArr[chekecdLength+(idex++)]
    + ";WebServer="+ RetArr[chekecdLength+(idex++)] + ";Agent="+ RetArr[chekecdLength+(idex++)] + ";Option="+ RetArr[chekecdLength+(idex++)] + ";Cowork="+ RetArr[chekecdLength+(idex++)]
    + ";ShareUser="+ RetArr[chekecdLength+(idex++)] + ";SharePath="+ RetArr[chekecdLength+(idex++)] + ";StartPath="+ RetArr[chekecdLength+(idex++)] + ";RealIP="+ RetArr[chekecdLength+(idex++)];
    
    MoveProcess(tmpParam, tmpCookie);
}

/* 파일 이동 수행
 * SeverMoveFile() -> SuccessMoveFile() -> MoveProcess()
 */
function MoveProcess(tmpParam, tmpCookie) {
    port = GetlocalStorage("port");
    if(tmpCheckedList.length > 0) {
        tmpparaData = "SrcName=" + tmpCheckedList[0] + tmpParam;
        tmpCheckedList.splice(0,1);
        
        authID = GetlocalStorage("UserID");
        AuthKey = GetlocalStorage("AuthKey");
        AuthMac = GetlocalStorage("mac");
        serviceID = GetlocalStorage("serviceID");
                                                                                                       
        paraData = "Server="+saveFileServer+"&Port="+port+"&Url="+"/PlusDrive/MoveFile"+"&CookieData="+tmpCookie+"&ParamData="+tmpparaData+"&AccountId="+authID+"&AuthKey="+AuthKey+"&mac="+AuthMac+"&serviceID="+serviceID;
        
        useProxy = GetlocalStorage("useProxy");
        if(useProxy == "true"){
            us = new ProxyConnect();
            us.proxyconn(function completeMoveProcess(RetVal){
                         result = RetVal.substring((RetVal.indexOf("\r\n"))+2);
                         
                         if("Success" != result.substring(0, 7)) {
                         if("Invalid Parameter" == result)
                         navigator.notification.alert(lang_alert_path_exists_err, null, 'Explorer', 'OK');
                         else
                         alertMessage(result);
                         }
                         MoveProcess(tmpParam,tmpCookie);
                         }, function(){alert('fail');}, protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);
        } else {
            RetVal = AjaxRequest(protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", paraData);
            result = RetVal.substring((RetVal.indexOf("\r\n"))+2);
            
            if("Success" != result.substring(0, 7)) {
                if("Invalid Parameter" == result)
                    navigator.notification.alert(lang_alert_path_exists_err, null, 'Explorer', 'OK');
                else if(result != "Auth Fail" && result != "etwork Err")
                    alertMessage(result);
                AM = new AppManager();
                setTimeout(function(){
                           AM.auth_get();
                           AM.finishapp();
                           }, 1000);
            }
            MoveProcess(tmpParam,tmpCookie);
        }
        
    } else if(tmpCheckedList.length <= 0) {
        showToast(toast_lang_move);
        refresh();
    }
}

// Local에서 Server로 파일 복사/이동 준비+++
function upload(overwrite, offset) {
    if(GetsessionStorage("tmpPicturePath") != null) {
        localpath= GetsessionStorage("tmpPicturePath");
        SetsessionStorage("tmpPicturePath", null);
    }
    /*
     token = tmpCheckedList[0].split("/");
     
     if(token[token.length-1])
     copypath = checked_list[0].value;
     else
     copypath = tmpLocalRootPath + tmpCheckedList[0].substring(11, checked_list[0].value.length);
     */
    
    if(overwrite == "" && offset == "") {
        localpath = "";
        
        for(var i = 0; i < tmpCheckedList.length; i++) {
            
            
            token = tmpCheckedList[0].split("/");
            
            if(i == 0){
                if(token[token.length-1])
                    localpath = tmpCheckedList[i];
                else
                    localpath = tmpLocalRootPath + tmpCheckedList[i].substring(11, tmpCheckedList[i].length);
            }
            else{
                localpath = localpath + "\t" + tmpCheckedList[i];
            }
        }
        
        length = tmpCheckedList.length;
        tmpCheckedList.splice(0,length);
    }
    
    Agent = GetlocalStorage("Platform");
    siteid = GetlocalStorage("SiteID");
    useSSL = GetlocalStorage("SSL");
    FileServerPort = "";
    
    if(useSSL == "yes")	FileServerPort = GetlocalStorage("FileSSlPort");
    else FileServerPort = GetlocalStorage("FileHttpPort");
    
    showUpDownProgressbar();
    upfile = setInterval(uploadprogress, 100);
    
    var token = localpath.split("/");
    
    if(token[token.length-1]){
        fullPath = tmpLocalRootPath+ECMFolder+ "/" + User + tmpLocalUserPath + "/" + token[token.length-1];
    } else {
        fullPath = tmpLocalRootPath+ECMFolder+ "/" + User + tmpLocalUserPath + "/" + token[token.length-2];
    }
    
    useProxy = GetlocalStorage("useProxy");
    updownmanager = new UpDownManager();
    updownmanager.upload(SuccessUpload, "", tmpDomainID, paraDiskType, User, tmpPartition, tmpWebServer, Agent, option, tmpOwner, tmpShareUser,
                         tmpShareOwner, tmpStartPath, tmpOrgCode, tmpUserPath, tmpFileServer, useSSL,FileServerPort, siteid, localpath, overwrite, offset, useProxy, fullPath);
}
                                                                                                       

/* Local에서 Server로 파일 복사/이동
 * upload() -> SuccessUpload()
 */
function SuccessUpload(retval) {
    if(retval == "Notexistingpath") {
        navigator.notification.alert(
                                     lang_alert_not_exists_path,
                                     null,
                                     'Explorer',
                                     'OK'
                                     );
    } else if(retval == "overwrite") {
        navigator.notification.confirm(
                                       lang_alert_overwrite,
                                       ConfirmOverwrite,
                                       'Explorer',
                                       'No,Yes'
                                       );
    } else if(retval == "offset") {
        navigator.notification.confirm(
                                       lang_alert_offset,
                                       confirmOffset,
                                       'Explorer',
                                       'No,Yes'
                                       );
    } else if(retval == "complete"){
        showToast(toast_lang_upload);
    } else {
        navigator.notification.alert(
                                     retval,
                                     null,
                                     'Explorer',
                                     'OK'
                                     );
    }
    
    clearInterval(upfile);
    clearInterval(upfileoverwrite);
    clearInterval(upfileoffset);
    hiddenUpDownProgressbar();
//    refresh();
}

/* 업로드 진행 상태
 * upload() -> uploadprogress()
 */
function uploadprogress() {
    tmpdeviceutil = new DeviceUtil();
    tmpdeviceutil.progress(getsize, "", "upload");
}

// Server로부터 파일 열기 준비
function getFile(filename, size, auth_check) {
                                                                                                       
                                                                                                       if ( "select" == nowMode ) {
                                                                                                       addSelectedFile(openTargetList);
                                                                                                       return;
                                                                                                       }
                                                                                                       
                                                                                                       tmpIndex = filename.lastIndexOf('.');
                                                                                                       tmpExtension = filename.substring(tmpIndex + 1).toLowerCase();
                                                                                                       if(tmpExtension != "pdf"){
                                                                                                       if(size >= 10000000 && size < 50000000){
                                                                                                       navigator.notification.confirm("대용량 문서는 조회 시간이 과다 소요됩니다.\n조회하시겠습니까?", function(button) {
                                                                                                                                      if ( button == 1)
                                                                                                                                      {
                                                                                                                                      $(openTargetList).css('background-color', '#E5F3FB');
                                                                                                                                      fileOpenFlag = 1;
                                                                                                                                      
                                                                                                                                      setTimeout(function(){
                                                                                                                                                 fileOpenFlag = 0;
                                                                                                                                                 }, 2000);
                                                                                                                                      
                                                                                                                                      if(filename.indexOf("NetID_apostrophe") != -1){
                                                                                                                                      filename = filename.replace("NetID_apostrophe", "'");
                                                                                                                                      }
                                                                                                                                      
                                                                                                                                      if(tmpUserPath.indexOf("/RECYCLER") != -1){
                                                                                                                                      return;
                                                                                                                                      }
                                                                                                                                      
                                                                                                                                      filename = filename.indexOf("NetID_apostrophe") > -1?   filename.replace(/NetID_apostrophe/gi, '\'') : filename;
                                                                                                                                      
                                                                                                                                      server = "npdocapp.koreanre.co.kr";
                                                                                                                                      port = "80";
                                                                                                                                      protocol = "http";
                                                                                                                                      
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
                                                                                                                                      
                                                                                                                                      retValue = AjaxRequest(protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", ServerInfoData);
                                                                                                                                      
                                                                                                                                      retValueArr = new Array();
                                                                                                                                      retValueArr = retValue.split("\r\n");
                                                                                                                                      if("version 1.0" == retValueArr[0].toLowerCase()) {
                                                                                                                                      if("success" == retValueArr[1].toLowerCase()) {
                                                                                                                                      
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
                                                                                                                                      
                                                                                                                                      tmpfilename = filename;
                                                                                                                                      tmpfilesize = size;
                                                                                                                                      
                                                                                                                                      if(auth_check.indexOf('r') != -1){
                                                                                                                                      index = filename.lastIndexOf('.');
                                                                                                                                      extension = filename.substring(index + 1).toLowerCase();
                                                                                                                                      file_open = GetlocalStorage("file_open");
                                                                                                                                      
                                                                                                                                      if(file_open == "app") {
                                                                                                                                      window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, LocalRootPath, null);
                                                                                                                                      } else {
                                                                                                                                      if(extension == "mp4" || extension == "avi" || extension == "3gp" || extension == "mp3" || extension == "wma" || extension == "mov"
                                                                                                                                         || extension == "jpg" || extension == "gif" || extension == "png" || extension == "doc" || extension == "docx"
                                                                                                                                         || extension == "ppt" || extension == "pptx"  || extension == "xls" || extension == "xlsx" || extension == "txt"
                                                                                                                                         || extension == "pdf" || extension == "hwp") {
                                                                                                                                      window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, LocalRootPath, null);
                                                                                                                                      } else {
                                                                                                                                      navigator.notification.alert(
                                                                                                                                                                   lang_alert_not_support_format,
                                                                                                                                                                   null,
                                                                                                                                                                   'Explorer',
                                                                                                                                                                   'OK'
                                                                                                                                                                   );
                                                                                                                                      }
                                                                                                                                      }
                                                                                                                                      } else {
                                                                                                                                      navigator.notification.confirm("파일 열기 권한이 없습니다.", function(){}, "", ["확인"]);
                                                                                                                                      return;
                                                                                                                                      }
                                                                                                                                      } else {
                                                                                                                                      return;
                                                                                                                                      }
                                                                                                                                      }, "", ["확인", "취소"]);
                                                                                                       } else if (size >= 50000000){
                                                                                                       navigator.notification.confirm("PDF 문서 외 50MB 이상의 문서는\n지원되지 않습니다.", function(button) {}, "", "확인");
                                                                                                       return;
                                                                                                       } else {
                                                                                                       $(openTargetList).css('background-color', '#E5F3FB');
                                                                                                       fileOpenFlag = 1;
                                                                                                       
                                                                                                       setTimeout(function(){
                                                                                                                  fileOpenFlag = 0;
                                                                                                                  }, 2000);
                                                                                                       
                                                                                                       if(filename.indexOf("NetID_apostrophe") != -1){
                                                                                                       filename = filename.replace("NetID_apostrophe", "'");
                                                                                                       }
                                                                                                       
                                                                                                       if(tmpUserPath.indexOf("/RECYCLER") != -1){
                                                                                                       return;
                                                                                                       }
                                                                                                       
                                                                                                       filename = filename.indexOf("NetID_apostrophe") > -1?   filename.replace(/NetID_apostrophe/gi, '\'') : filename;
                                                                                                       
                                                                                                       server = "npdocapp.koreanre.co.kr";
                                                                                                       port = "80";
                                                                                                       protocol = "http";
                                                                                                       
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
                                                                                                       
                                                                                                       retValue = AjaxRequest(protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", ServerInfoData);
                                                                                                       
                                                                                                       retValueArr = new Array();
                                                                                                       retValueArr = retValue.split("\r\n");
                                                                                                       if("version 1.0" == retValueArr[0].toLowerCase()) {
                                                                                                       if("success" == retValueArr[1].toLowerCase()) {
                                                                                                       
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
                                                                                                       
                                                                                                       tmpfilename = filename;
                                                                                                       tmpfilesize = size;
                                                                                                       
                                                                                                       if(auth_check.indexOf('r') != -1){
                                                                                                       index = filename.lastIndexOf('.');
                                                                                                       extension = filename.substring(index + 1).toLowerCase();
                                                                                                       file_open = GetlocalStorage("file_open");
                                                                                                       
                                                                                                       if(file_open == "app") {
                                                                                                       window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, LocalRootPath, null);
                                                                                                       } else {
                                                                                                       if(extension == "mp4" || extension == "avi" || extension == "3gp" || extension == "mp3" || extension == "wma" || extension == "mov"
                                                                                                          || extension == "jpg" || extension == "gif" || extension == "png" || extension == "doc" || extension == "docx"
                                                                                                          || extension == "ppt" || extension == "pptx"  || extension == "xls" || extension == "xlsx" || extension == "txt"
                                                                                                          || extension == "pdf" || extension == "hwp") {
                                                                                                       window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, LocalRootPath, null);
                                                                                                       } else {
                                                                                                       navigator.notification.alert(
                                                                                                                                    lang_alert_not_support_format,
                                                                                                                                    null,
                                                                                                                                    'Explorer',
                                                                                                                                    'OK'
                                                                                                                                    );
                                                                                                       }
                                                                                                       }
                                                                                                       } else {
                                                                                                       navigator.notification.confirm("파일 열기 권한이 없습니다.", function(){}, "", ["확인"]);
                                                                                                       return;
                                                                                                       }
                                                                                                       }
                                                                                                       } else {
                                                                                                       $(openTargetList).css('background-color', '#E5F3FB');
                                                                                                       fileOpenFlag = 1;
                                                                                                       
                                                                                                       setTimeout(function(){
                                                                                                                  fileOpenFlag = 0;
                                                                                                                  }, 2000);
                                                                                                       
                                                                                                       if(filename.indexOf("NetID_apostrophe") != -1){
                                                                                                       filename = filename.replace("NetID_apostrophe", "'");
                                                                                                       }
                                                                                                       
                                                                                                       if(tmpUserPath.indexOf("/RECYCLER") != -1){
                                                                                                       return;
                                                                                                       }
                                                                                                       
                                                                                                       filename = filename.indexOf("NetID_apostrophe") > -1?   filename.replace(/NetID_apostrophe/gi, '\'') : filename;
                                                                                                       
                                                                                                       server = "npdocapp.koreanre.co.kr";
                                                                                                       port = "80";
                                                                                                       protocol = "http";
                                                                                                       
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
                                                                                                       
                                                                                                       retValue = AjaxRequest(protocol, port, server, "POST", "/webapp/protocal_mgmt.jsp", ServerInfoData);
                                                                                                       
                                                                                                       retValueArr = new Array();
                                                                                                       retValueArr = retValue.split("\r\n");
                                                                                                       if("version 1.0" == retValueArr[0].toLowerCase()) {
                                                                                                       if("success" == retValueArr[1].toLowerCase()) {
                                                                                                       
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
                                                                                                       
                                                                                                       tmpfilename = filename;
                                                                                                       tmpfilesize = size;
                                                                                                       
                                                                                                       if(auth_check.indexOf('r') != -1){
                                                                                                       index = filename.lastIndexOf('.');
                                                                                                       extension = filename.substring(index + 1).toLowerCase();
                                                                                                       file_open = GetlocalStorage("file_open");
                                                                                                       
                                                                                                       if(file_open == "app") {
                                                                                                       window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, LocalRootPath, null);
                                                                                                       } else {
                                                                                                       if(extension == "mp4" || extension == "avi" || extension == "3gp" || extension == "mp3" || extension == "wma" || extension == "mov"
                                                                                                          || extension == "jpg" || extension == "gif" || extension == "png" || extension == "doc" || extension == "docx"
                                                                                                          || extension == "ppt" || extension == "pptx"  || extension == "xls" || extension == "xlsx" || extension == "txt"
                                                                                                          || extension == "pdf" || extension == "hwp") {
                                                                                                       window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, LocalRootPath, null);
                                                                                                       } else {
                                                                                                       navigator.notification.alert(
                                                                                                                                    lang_alert_not_support_format,
                                                                                                                                    null,
                                                                                                                                    'Explorer',
                                                                                                                                    'OK'
                                                                                                                                    );
                                                                                                       }
                                                                                                       }
                                                                                                       } else {
                                                                                                       navigator.notification.confirm("파일 열기 권한이 없습니다.", function(){}, "", ["확인"]);
                                                                                                       return;
                                                                                                       }
                                                                                                       }
                                                                                                       
    
}
                                                                                                       
/* 열을 파일 경로 확인
 * getFile() -> LocalRootPath()
 */
function LocalRootPath(fileSystem) {
    var LocalRoot = fileSystem.root.name;
    
    if(LocalRoot != "sdcard") LocalRoot = "sdcard";
    
    srcName = (tmpUserPath+"/"+tmpfilename).replace("//", "/");
    tmpLocalRootPath = "/" + LocalRoot;
    checkConnection("fileopen");
}

/* Server파일 열기
 * getFile() -> LocalRootPath() -> fileopen()
 */
                                                                                                       
var pdfCheck = 0;
function fileopen(overwrite, offset) {
    tmpname = srcName.substring(srcName.lastIndexOf('/'));
    index = tmpname.lastIndexOf('.');
    extension = tmpname.substring(index + 1).toLowerCase();
    
    viewer = GetlocalStorage("Officesuite");
    file_open = GetlocalStorage("file_open");
    
    if( file_open != "app" ){
        if(extension == "doc" || extension == "docx" || extension == "ppt" || extension == "pptx"
           || extension == "xls" || extension == "xlsx" || extension == "txt" || extension == "pdf"){
            if( file_open == "viewer" && viewer == "nonexistent"  ){
                //alert("not exist Officesuite");
                alertMessage("not installed officesuite");
                return;
            }
        }
    }
    
    tmpLocalpath = tmpLocalRootPath +"/ECM";
    attribute = "0";
    siteid = GetlocalStorage("SiteID");
    option = "";
    Agent = GetlocalStorage("Platform");
    if(paraDiskType == "personal") option = "0x01";
    
    useSSL = GetlocalStorage("SSL");
    FileServerPort = "";
    if(useSSL == "yes") FileServerPort = GetlocalStorage("FileSSlPort");
    else FileServerPort = GetlocalStorage("FileHttpPort");
    
    cookie = tmpDomainID + "\t" + tmpDiskType + "\t" + User + "\t" + tmpPartition + "\t" + tmpWebServer + "\t" + Agent + "\t" + option + "\t" + tmpOwner + "\t" + tmpShareUser + "\t" + tmpShareOwner + "\t" + tmpStartPath;
    parameter = srcName + "\t" + cookie;
                
                                                                                                       var fileInfo = "file" + "\t" + paraDiskType + "\t" + tmpPartition + "\t" + option + "\t" + tmpOwner + "\t" + tmpShareUser + "\t" + tmpShareOwner + "\t" + tmpStartPath + "\t" + tmpOrgCode + "\t" + tmpFileServer + "\t" + tmpfilesize + "\trdef"; //@
                                                                                                       var path = tmpUserPath == "/"?  paraDiskType + tmpUserPath + tmpname.slice(1) : paraDiskType + tmpUserPath + "/" + tmpname.slice(1);
                                                                                                       
                                                                                                       try{
                                                                                                       Entertainment = new Entertainment();
                                                                                                       Entertainment.appendBM(function(result) {
                                                                                                                              if ( result == "exist" )
                                                                                                                              {
                                                                                                                              try{
                                                                                                                              Entertainment = new Entertainment();
                                                                                                                              Entertainment.removeBM(function(){
                                                                                                                                                     try{
                                                                                                                                                     Entertainment = new Entertainment();
                                                                                                                                                     Entertainment.appendBM(function(result) {}, function(){}, User, "최근 문서", path, fileInfo);
                                                                                                                                                     }catch(e){
                                                                                                                                                     Entertainment.appendBM(function(result) {}, function(){}, User, "최근 문서", path, fileInfo);
                                                                                                                                                     }
                                                                                                                                                     }, function(){}, User, "최근 문서", path);
                                                                                                                              }catch(e){
                                                                                                                              Entertainment.removeBM(function(){
                                                                                                                                                     try{
                                                                                                                                                     Entertainment = new Entertainment();
                                                                                                                                                     Entertainment.appendBM(function(result) {}, function(){}, User, "최근 문서", path, fileInfo);
                                                                                                                                                     }catch(e){
                                                                                                                                                     Entertainment.appendBM(function(result) {}, function(){}, User, "최근 문서", path, fileInfo);
                                                                                                                                                     }
                                                                                                                                                     }, function(){}, User, "최근 문서", path);
                                                                                                                              }
                                                                                                                              }
                                                                                                                              }, function(){}, User, "최근 문서", path, fileInfo);
                                                                                                       }catch(e){
                                                                                                       Entertainment.appendBM(function(result) {
                                                                                                                              if ( result == "exist" )
                                                                                                                              {
                                                                                                                              try{
                                                                                                                              Entertainment = new Entertainment();
                                                                                                                              Entertainment.removeBM(function(){
                                                                                                                                                     try{
                                                                                                                                                     Entertainment = new Entertainment();
                                                                                                                                                     Entertainment.appendBM(function(result) {}, function(){}, User, "최근 문서", path, fileInfo);
                                                                                                                                                     }catch(e){
                                                                                                                                                     Entertainment.appendBM(function(result) {}, function(){}, User, "최근 문서", path, fileInfo);
                                                                                                                                                     }
                                                                                                                                                     }, function(){}, User, "최근 문서", path);
                                                                                                                              }catch(e){
                                                                                                                              Entertainment.removeBM(function(){
                                                                                                                                                     try{
                                                                                                                                                     Entertainment = new Entertainment();
                                                                                                                                                     Entertainment.appendBM(function(result) {}, function(){}, User, "최근 문서", path, fileInfo);
                                                                                                                                                     }catch(e){
                                                                                                                                                     Entertainment.appendBM(function(result) {}, function(){}, User, "최근 문서", path, fileInfo);
                                                                                                                                                     }
                                                                                                                                                     }, function(){}, User, "최근 문서", path);
                                                                                                                              }
                                                                                                                              }
                                                                                                                              }, function(){}, User, "최근 문서", path, fileInfo);
                                                                                                       }
                                                                                                       
                                                                                                       
    if(extension == "xlsx" || extension == "xls" || extension == "doc" || extension == "docx" || extension == "hwp" || extension == "ppt" || extension == "pptx"){
//        alert("tmpDomainID: " + tmpDomainID + "\nparaDiskType: " + paraDiskType + "\nUser: " + User + "\ntmpPartition: " + tmpPartition + "\ntmpWebServer: " + tmpWebServer + "\nAgent: " + Agent + "\noption: " + option + "\ntmpOwner: " + tmpOwner + "\ntmpShareUser: " + tmpShareUser + "\ntmpShareOwner: " + tmpShareOwner + "\ntmpStartPath: " + tmpStartPath + "\ntmpOrgCode: " + tmpOrgCode + "\nsrcName: " + srcName + "\ntmpFileServer: " + tmpFileServer + "\nuseSSL: " + useSSL + "\nFileServerPort: " + FileServerPort + "\nfileopen: " + "fileopen" + "\nsiteid: " + siteid + "\nattribute: " + attribute + "\ntmpfilesize: " + tmpfilesize + "\ntmpLocalpath: " + tmpLocalpath + "\noverwrite: " + overwrite + "\noffset: " + offset);
                                                                                                       useProxy = GetlocalStorage("useProxy");
                                                                                                       updownmanager = new UpDownManager();
                                                                                                       updownmanager.download(SuccessFileOpen, failMsg, tmpDomainID, paraDiskType, User, tmpPartition, tmpWebServer, Agent, option, tmpOwner, tmpShareUser,
                                                                                                                              tmpShareOwner, tmpStartPath, tmpOrgCode, srcName, tmpFileServer,useSSL,FileServerPort, "fileopen", siteid, attribute,tmpfilesize, tmpLocalpath, overwrite, offset, useProxy, "no");
//                                                                                                               try{
//            CryptUtil = new CryptUtil();
//            CryptUtil.call(function(r){
//                           RetArr = new Array();
//                           RetArr = r.split("\t");
//                           tmpparaData = "SrcName=" + RetArr[0];
//                           tmpCookie = "DomainID="+ RetArr[1] + ";DiskType="+ RetArr[2] + ";User="+ RetArr[3] + ";Partition="+ RetArr[4] + ";WebServer="+ RetArr[5] + ";Agent="+ RetArr[6] + ";Option="+ RetArr[7] + ";Cowork="+ RetArr[8] + ";ShareUser="+ RetArr[9] + ";SharePath="+ RetArr[10] + ";StartPath="+ RetArr[11] + ";RealIP="+ RetArr[12];
//                           
//                           url = "http://npdocapp.koreanre.co.kr/webapp/custom_file_download_by_pdf.jsp?CookieData="+tmpCookie+"&ParamData="+tmpparaData;
//
//                           window.open(url , "_blank", "location=no");
//                           
//                           if(GetlocalStorage("clickDrive") == 1 || pdfCheck == 1){
//                           setTimeout(function(){
//                                      window.open(url , "_blank", "location=no");
//                                      }, 500);
//                           SetlocalStorage("clickDrive", 0);
//                           beforeDriveName = nowDriveName;
//                           }
//                           }, "", parameter, GetlocalStorage("SiteID"));
//        }catch(e){
//            CryptUtil.call(function(r){
//                           RetArr = new Array();
//                           RetArr = r.split("\t");
//                           tmpparaData = "SrcName=" + RetArr[0];
//                           tmpCookie = "DomainID="+ RetArr[1] + ";DiskType="+ RetArr[2] + ";User="+ RetArr[3] + ";Partition="+ RetArr[4] + ";WebServer="+ RetArr[5] + ";Agent="+ RetArr[6] + ";Option="+ RetArr[7] + ";Cowork="+ RetArr[8] + ";ShareUser="+ RetArr[9] + ";SharePath="+ RetArr[10] + ";StartPath="+ RetArr[11] + ";RealIP="+ RetArr[12];
//                           
//                           url = "http://npdocapp.koreanre.co.kr/webapp/custom_file_download_by_pdf.jsp?CookieData="+tmpCookie+"&ParamData="+tmpparaData;
//                           
//                           window.open(url , "_blank", "location=no");
//                           
//                           if(GetlocalStorage("clickDrive") == 1 && beforeDriveName != nowDriveName || beforeDriveName == "none" || pdfCheck == 1){
//                           setTimeout(function(){
//                                      window.open(url , "_blank", "location=no");
//                                      }, 500);
//                           SetlocalStorage("clickDrive", 0);
//                           beforeDriveName = nowDriveName;
//                           pdfCheck = 0;
//                           }
//                           }, "", parameter, GetlocalStorage("SiteID"));
//        }
    } else if(extension == "txt" || extension == "jpg" || extension == "jpeg" || extension == "png") {
              useProxy = GetlocalStorage("useProxy");
              updownmanager = new UpDownManager();
              updownmanager.download(SuccessFileOpen, failMsg, tmpDomainID, paraDiskType, User, tmpPartition, tmpWebServer, Agent, option, tmpOwner, tmpShareUser,
                                     tmpShareOwner, tmpStartPath, tmpOrgCode, srcName, tmpFileServer,useSSL,FileServerPort, "fileopen", siteid, attribute,tmpfilesize, tmpLocalpath, overwrite, offset, useProxy, "no");
//              if(GetlocalStorage("clickDrive") == 1 && beforeDriveName != nowDriveName || beforeDriveName == "none"){
//                  useProxy = GetlocalStorage("useProxy");
//                  updownmanager = new UpDownManager();
//                                                                                                       if(GetlocalStorage("clickDrive") == 1 && beforeDriveName != nowDriveName || beforeDriveName == "none"){
//                                                                                                       setTimeout(function(){
//                                                                                                                  updownmanager.download(SuccessFileOpen, failMsg, tmpDomainID, paraDiskType, User, tmpPartition, tmpWebServer, Agent, option, tmpOwner, tmpShareUser,tmpShareOwner, tmpStartPath, tmpOrgCode, srcName, tmpFileServer,useSSL,FileServerPort, "fileopen", siteid, attribute,tmpfilesize, tmpLocalpath, overwrite, offset, useProxy, "no");
//                                                                                                                  }, 500);
//                                                                                                       SetlocalStorage("clickDrive", 0);
//                                                                                                       beforeDriveName = nowDriveName;
//                                                                                                       }
                  
//                  SetlocalStorage("clickDrive", 0);
//                  beforeDriveName = nowDriveName;
//              }
    } else {
//        try{
//            CryptUtil = new CryptUtil();
//            CryptUtil.call(function(r){
//                           RetArr = new Array();
//                           RetArr = r.split("\t");
//                           tmpparaData = "SrcName=" + RetArr[0];
//                           tmpCookie = "DomainID="+ RetArr[1] + ";DiskType="+ RetArr[2] + ";User="+ RetArr[3] + ";Partition="+ RetArr[4] + ";WebServer="+ RetArr[5] + ";Agent="+ RetArr[6] + ";Option="+ RetArr[7] + ";Cowork="+ RetArr[8] + ";ShareUser="+ RetArr[9] + ";SharePath="+ RetArr[10] + ";StartPath="+ RetArr[11] + ";RealIP="+ RetArr[12];
//                           
//                           url = "http://npdocapp.koreanre.co.kr/webapp/custom_file_download2.jsp?CookieData="+tmpCookie+"&ParamData="+tmpparaData;
//
//                           window.open(url , "_blank", "location=no");
//                           
//                           if(GetlocalStorage("clickDrive") == 1){
//                           setTimeout(function(){
//                                      window.open(url , "_blank", "location=no");
//                                      }, 500);
//                           SetlocalStorage("clickDrive", 0);
//                           beforeDriveName = nowDriveName;
//                           }
//                           }, "", parameter, GetlocalStorage("SiteID"));
//        }catch(e){
//            CryptUtil.call(function(r){
//                           RetArr = new Array();
//                           RetArr = r.split("\t");
//                           tmpparaData = "SrcName=" + RetArr[0];
//                           tmpCookie = "DomainID="+ RetArr[1] + ";DiskType="+ RetArr[2] + ";User="+ RetArr[3] + ";Partition="+ RetArr[4] + ";WebServer="+ RetArr[5] + ";Agent="+ RetArr[6] + ";Option="+ RetArr[7] + ";Cowork="+ RetArr[8] + ";ShareUser="+ RetArr[9] + ";SharePath="+ RetArr[10] + ";StartPath="+ RetArr[11] + ";RealIP="+ RetArr[12];
//                           
//                           url = "http://npdocapp.koreanre.co.kr/webapp/custom_file_download2.jsp?CookieData="+tmpCookie+"&ParamData="+tmpparaData;
//                           
//                           window.open(url , "_blank", "location=no");
//                           
//                           if(GetlocalStorage("clickDrive") == 1 && beforeDriveName != nowDriveName || beforeDriveName == "none"){
//                           setTimeout(function(){
//                                      window.open(url , "_blank", "location=no");
//                                      }, 500);
//                           SetlocalStorage("clickDrive", 0);
//                           beforeDriveName = nowDriveName;
//                           }
//                           }, "", parameter, GetlocalStorage("SiteID"));
//        }
        /*
         showUpDownProgressbar();
         downfile = setInterval(downloadprogress, 100);
         
         useProxy = GetlocalStorage("useProxy");
         updownmanager = new UpDownManager();
         updownmanager.download(SuccessFileOpen, failMsg, tmpDomainID, paraDiskType, User, tmpPartition, tmpWebServer, Agent, option, tmpOwner, tmpShareUser,
         tmpShareOwner, tmpStartPath, tmpOrgCode, srcName, tmpFileServer,useSSL,FileServerPort, "fileopen", siteid, attribute,tmpfilesize, tmpLocalpath, overwrite, offset, useProxy);
         */
                                                                                                       
                                                                                                       try{
                                                                                                       useProxy = GetlocalStorage("useProxy");
                                                                                                       updownmanager = new UpDownManager();
                                                                                                       updownmanager.download(SuccessFileOpen, failMsg, tmpDomainID, paraDiskType, User, tmpPartition, tmpWebServer, Agent, option, tmpOwner, tmpShareUser,
                                                                                                                              tmpShareOwner, tmpStartPath, tmpOrgCode, srcName, tmpFileServer,useSSL,FileServerPort, "fileopen", siteid, attribute,tmpfilesize, tmpLocalpath, overwrite, offset, useProxy, "no");
                                                                                                       }catch(e){
//                                                                                                       alert('err = ' + e);
                                                                                                       }
                                                                                                       //              if(GetlocalStorage("clickDrive") == 1 && beforeDriveName != nowDriveName || beforeDriveName == "none"){
                                                                                                       //                  useProxy = GetlocalStorage("useProxy");
                                                                                                       //                  updownmanager = new UpDownManager();
//                                                                                                       if(GetlocalStorage("clickDrive") == 1 && beforeDriveName != nowDriveName || beforeDriveName == "none" || pdfCheck == 1){
//                                                                                                       setTimeout(function(){
//                                                                                                                  updownmanager.download(SuccessFileOpen, failMsg, tmpDomainID, paraDiskType, User, tmpPartition, tmpWebServer, Agent, option, tmpOwner, tmpShareUser,tmpShareOwner, tmpStartPath, tmpOrgCode, srcName, tmpFileServer,useSSL,FileServerPort, "fileopen", siteid, attribute,tmpfilesize, tmpLocalpath, overwrite, offset, useProxy);
//                                                                                                                  }, 500);
//                                                                                                       SetlocalStorage("clickDrive", 0);
//                                                                                                       beforeDriveName = nowDriveName;
//                                                                                                       pdfCheck = 0;
//                                                                                                       }
                                                                                                       
                                                                                                       }
                                                                                                       
                                                                                                       pdfCheck = 1;
    
    
    
    //    useProxy = GetlocalStorage("useProxy");
    //	updownmanager = new UpDownManager();
    //	updownmanager.download(SuccessFileOpen, failMsg, tmpDomainID, paraDiskType, User, tmpPartition, tmpWebServer, Agent, option, tmpOwner, tmpShareUser,
    //			tmpShareOwner, tmpStartPath, tmpOrgCode, srcName, tmpFileServer,useSSL,FileServerPort, "fileopen", siteid, attribute,tmpfilesize, tmpLocalpath, overwrite, offset, useProxy);
}

/* 파일 열어 보기
 * getFile() -> LocalRootPath() -> fileopen() -> SuccessFileOpen()
 */
function SuccessFileOpen(r) {
                                                                                                       if(r == "열려있는 문서가 없습니다."){
                                                                                                       navigator.notification.alert("열려있는 문서가 없습니다.", function(){}, "", "확인");
                                                                                                       return;
                                                                                                       }
    clearInterval(downfile);
    hiddenUpDownProgressbar();
    
    if(r == "exists") {
        navigator.notification.alert(
                                     lang_already_folder_exists,
                                     null,
                                     'Explorer',
                                     'OK'
                                     );
    } else if(r == "Notexistingpath") {
        navigator.notification.alert(
                                     lang_alert_not_exists_path,
                                     null,
                                     'Explorer',
                                     'OK'
                                     );
    } else if(r == "Failed") {
        navigator.notification.alert(
                                     lang_alert_create_folder_fail,
                                     null,
                                     'Explorer',
                                     'OK'
                                     );
    } else if(r == "overwrite") {
        navigator.notification.confirm(
                                       lang_alert_overwrite,
                                       ConfirmFileOpenOverwrite,
                                       'Explorer',
                                       'No,Yes'
                                       );
    } else if(r == "offset") {
        /*navigator.notification.confirm(
         lang_alert_offset,
         confirmFileOpenOffset,
         'Explorer',
         'No,Yes'
         );*/
        confirmFileOpenOffset();
    } else if(r == "Canceled") {
        navigator.notification.alert("경로를 찾을 수 없습니다.", function(){}, "", "확인");
    } else if(r != "complete") {
                                                                                                       var documentPreview = GetlocalStorage("documentPreview") == null? "unuse" : GetlocalStorage("documentPreview");
                                                                                                       //                                                                                                       r += "netid_&";
                                                                                                       //                                                                                                       r += documentPreview;
                                                                                                       
                                                                                                       var filepath = r.split('\t');
                                                                                                       for ( var i in filepath ) {
                                                                                                       var path = filepath[i];
                                                                                                       path += "netid_&";
                                                                                                       path += documentPreview;
                                                                                                       path += "netid_&";
                                                                                                       if(i==filepath.length-1) path += "end";
                                                                                                       else path += "nend";
                                                                                                       window.open(path, "_blank", "location=no");
                                                                                                       }
    } else {
        tmpLocalpath = tmpLocalRootPath +"/ECM/dcrypt_tmp/" + tmpfilename;
        openFile(tmpLocalpath, "Server");
    }
}

function FileURL(r){
    //tmpdeviceutil = new DeviceUtil();
    //tmpdeviceutil.alert(function(){},function(){},r);
    //alert(r);
    navigator.notification.alert(
                                 r,
                                 null,
                                 'Login',
                                 'OK'
                                 );
}

/* Upload()시 덮어쓰기
 * upload() -> SuccessUpload() -> ConfirmOverwrite()
 */
function ConfirmOverwrite(value) {
    clearInterval(upfile);
    hiddenUpDownProgressbar();
    if(value == "2") upload("yes", "no");
    else upload("no", "no");
}

function confirmOffset( value )
{
    clearInterval(upfile);
    hiddenUpDownProgressbar();
    if( value == "2" )
    {
        upload("no", "yes");
    }
    else
    {
        upload("no", "no");
    }
}

// 이미 존재하는 파일 열기
function ConfirmFileOpenOverwrite(value) {
    if(value == "2")
        fileopen("yes", "no");
    else
        fileopen("no", "no");
}

function confirmFileOpenOffset(value) {
    fileopen("no", "no");
}

/*
 //Check 3G Upload
 function CheckNetwork(){
 checkNetwork = new DeviceUtil();
 checkNetwork.Use3G(NetworkInfo,"");
 }
 
 function NetworkInfo(retVal){
 if(retVal == "no" || GetlocalStorage("Use3GUp") == "yes"){
 upload("","");
 }else{
 var bAnswer = confirm("3G�� ����� ������ ��ȭ�ᰡ �ΰ��� �� �ֽ��ϴ�."+<br>+"��� �Ͻðڽ��ϱ�?");
 if(bAnswer  == true)
 upload("","");
 else
 return;
 }
 }
 
 */


                                                                                                       // 뷰어로 되돌아가기
                                                                                                       function backToViewer(){
                                                                                                       try{
                                                                                                       
                                                                                                       var srcName = "backViewer";
                                                                                                       var overwrite = "";
                                                                                                       var offset = "";
                                                                                                       
                                                                                                       tmpname = srcName.substring(srcName.lastIndexOf('/'));
                                                                                                       index = tmpname.lastIndexOf('.');
                                                                                                       extension = tmpname.substring(index + 1).toLowerCase();
                                                                                                       
                                                                                                       viewer = GetlocalStorage("Officesuite");
                                                                                                       file_open = GetlocalStorage("file_open");
                                                                                                       
                                                                                                       //    if( file_open != "app" ){
                                                                                                       //        if(extension == "doc" || extension == "docx" || extension == "ppt" || extension == "pptx"
                                                                                                       //           || extension == "xls" || extension == "xlsx" || extension == "txt" || extension == "pdf"){
                                                                                                       //            if( file_open == "viewer" && viewer == "nonexistent"  ){
                                                                                                       //                //alert("not exist Officesuite");
                                                                                                       //                alertMessage("not installed officesuite");
                                                                                                       //                return;
                                                                                                       //            }
                                                                                                       //        }
                                                                                                       //    }
                                                                                                       
                                                                                                       tmpLocalpath = tmpLocalRootPath +"/ECM";
                                                                                                       attribute = "0";
                                                                                                       siteid = GetlocalStorage("SiteID");
                                                                                                       option = "";
                                                                                                       Agent = GetlocalStorage("Platform");
                                                                                                       if(paraDiskType == "personal") option = "0x01";
                                                                                                       
                                                                                                       useSSL = GetlocalStorage("SSL");
                                                                                                       FileServerPort = "";
                                                                                                       if(useSSL == "yes") FileServerPort = GetlocalStorage("FileSSlPort");
                                                                                                       else FileServerPort = GetlocalStorage("FileHttpPort");
                                                                                                       
                                                                                                       cookie = tmpDomainID + "\t" + tmpDiskType + "\t" + User + "\t" + tmpPartition + "\t" + tmpWebServer + "\t" + Agent + "\t" + option + "\t" + tmpOwner + "\t" + tmpShareUser + "\t" + tmpShareOwner + "\t" + tmpStartPath;
                                                                                                       parameter = srcName + "\t" + cookie;
                                                                                                       
                                                                                                       if(extension == "xlsx" || extension == "xls" || extension == "doc" || extension == "docx" || extension == "hwp" || extension == "ppt" || extension == "pptx"){
                                                                                                       //        alert("tmpDomainID: " + tmpDomainID + "\nparaDiskType: " + paraDiskType + "\nUser: " + User + "\ntmpPartition: " + tmpPartition + "\ntmpWebServer: " + tmpWebServer + "\nAgent: " + Agent + "\noption: " + option + "\ntmpOwner: " + tmpOwner + "\ntmpShareUser: " + tmpShareUser + "\ntmpShareOwner: " + tmpShareOwner + "\ntmpStartPath: " + tmpStartPath + "\ntmpOrgCode: " + tmpOrgCode + "\nsrcName: " + srcName + "\ntmpFileServer: " + tmpFileServer + "\nuseSSL: " + useSSL + "\nFileServerPort: " + FileServerPort + "\nfileopen: " + "fileopen" + "\nsiteid: " + siteid + "\nattribute: " + attribute + "\ntmpfilesize: " + tmpfilesize + "\ntmpLocalpath: " + tmpLocalpath + "\noverwrite: " + overwrite + "\noffset: " + offset);
                                                                                                       useProxy = GetlocalStorage("useProxy");
                                                                                                       updownmanager = new UpDownManager();
                                                                                                       updownmanager.download(SuccessFileOpen, failMsg, tmpDomainID, paraDiskType, User, tmpPartition, tmpWebServer, Agent, option, tmpOwner, tmpShareUser,
                                                                                                                              tmpShareOwner, tmpStartPath, tmpOrgCode, "backViewer", tmpFileServer,useSSL,FileServerPort, "fileopen", siteid, attribute,tmpfilesize, tmpLocalpath, overwrite, offset, useProxy, "no");
                                                                                                       //                                                                                                               try{
                                                                                                       //            CryptUtil = new CryptUtil();
                                                                                                       //            CryptUtil.call(function(r){
                                                                                                       //                           RetArr = new Array();
                                                                                                       //                           RetArr = r.split("\t");
                                                                                                       //                           tmpparaData = "SrcName=" + RetArr[0];
                                                                                                       //                           tmpCookie = "DomainID="+ RetArr[1] + ";DiskType="+ RetArr[2] + ";User="+ RetArr[3] + ";Partition="+ RetArr[4] + ";WebServer="+ RetArr[5] + ";Agent="+ RetArr[6] + ";Option="+ RetArr[7] + ";Cowork="+ RetArr[8] + ";ShareUser="+ RetArr[9] + ";SharePath="+ RetArr[10] + ";StartPath="+ RetArr[11] + ";RealIP="+ RetArr[12];
                                                                                                       //
                                                                                                       //                           url = "http://npdocapp.koreanre.co.kr/webapp/custom_file_download_by_pdf.jsp?CookieData="+tmpCookie+"&ParamData="+tmpparaData;
                                                                                                       //
                                                                                                       //                           window.open(url , "_blank", "location=no");
                                                                                                       //
                                                                                                       //                           if(GetlocalStorage("clickDrive") == 1 || pdfCheck == 1){
                                                                                                       //                           setTimeout(function(){
                                                                                                       //                                      window.open(url , "_blank", "location=no");
                                                                                                       //                                      }, 500);
                                                                                                       //                           SetlocalStorage("clickDrive", 0);
                                                                                                       //                           beforeDriveName = nowDriveName;
                                                                                                       //                           }
                                                                                                       //                           }, "", parameter, GetlocalStorage("SiteID"));
                                                                                                       //        }catch(e){
                                                                                                       //            CryptUtil.call(function(r){
                                                                                                       //                           RetArr = new Array();
                                                                                                       //                           RetArr = r.split("\t");
                                                                                                       //                           tmpparaData = "SrcName=" + RetArr[0];
                                                                                                       //                           tmpCookie = "DomainID="+ RetArr[1] + ";DiskType="+ RetArr[2] + ";User="+ RetArr[3] + ";Partition="+ RetArr[4] + ";WebServer="+ RetArr[5] + ";Agent="+ RetArr[6] + ";Option="+ RetArr[7] + ";Cowork="+ RetArr[8] + ";ShareUser="+ RetArr[9] + ";SharePath="+ RetArr[10] + ";StartPath="+ RetArr[11] + ";RealIP="+ RetArr[12];
                                                                                                       //
                                                                                                       //                           url = "http://npdocapp.koreanre.co.kr/webapp/custom_file_download_by_pdf.jsp?CookieData="+tmpCookie+"&ParamData="+tmpparaData;
                                                                                                       //
                                                                                                       //                           window.open(url , "_blank", "location=no");
                                                                                                       //
                                                                                                       //                           if(GetlocalStorage("clickDrive") == 1 && beforeDriveName != nowDriveName || beforeDriveName == "none" || pdfCheck == 1){
                                                                                                       //                           setTimeout(function(){
                                                                                                       //                                      window.open(url , "_blank", "location=no");
                                                                                                       //                                      }, 500);
                                                                                                       //                           SetlocalStorage("clickDrive", 0);
                                                                                                       //                           beforeDriveName = nowDriveName;
                                                                                                       //                           pdfCheck = 0;
                                                                                                       //                           }
                                                                                                       //                           }, "", parameter, GetlocalStorage("SiteID"));
                                                                                                       //        }
                                                                                                       } else if(extension == "txt" || extension == "jpg" || extension == "jpeg" || extension == "png") {
                                                                                                       useProxy = GetlocalStorage("useProxy");
                                                                                                       updownmanager = new UpDownManager();
                                                                                                       updownmanager.download(SuccessFileOpen, failMsg, tmpDomainID, paraDiskType, User, tmpPartition, tmpWebServer, Agent, option, tmpOwner, tmpShareUser,
                                                                                                                              tmpShareOwner, tmpStartPath, tmpOrgCode, "backViewer", tmpFileServer,useSSL,FileServerPort, "fileopen", siteid, attribute,tmpfilesize, tmpLocalpath, overwrite, offset, useProxy, "no");
                                                                                                       //              if(GetlocalStorage("clickDrive") == 1 && beforeDriveName != nowDriveName || beforeDriveName == "none"){
                                                                                                       //                  useProxy = GetlocalStorage("useProxy");
                                                                                                       //                  updownmanager = new UpDownManager();
                                                                                                       //                                                                                                       if(GetlocalStorage("clickDrive") == 1 && beforeDriveName != nowDriveName || beforeDriveName == "none"){
                                                                                                       //                                                                                                       setTimeout(function(){
                                                                                                       //                                                                                                                  updownmanager.download(SuccessFileOpen, failMsg, tmpDomainID, paraDiskType, User, tmpPartition, tmpWebServer, Agent, option, tmpOwner, tmpShareUser,tmpShareOwner, tmpStartPath, tmpOrgCode, srcName, tmpFileServer,useSSL,FileServerPort, "fileopen", siteid, attribute,tmpfilesize, tmpLocalpath, overwrite, offset, useProxy, "no");
                                                                                                       //                                                                                                                  }, 500);
                                                                                                       //                                                                                                       SetlocalStorage("clickDrive", 0);
                                                                                                       //                                                                                                       beforeDriveName = nowDriveName;
                                                                                                       //                                                                                                       }
                                                                                                       
                                                                                                       //                  SetlocalStorage("clickDrive", 0);
                                                                                                       //                  beforeDriveName = nowDriveName;
                                                                                                       //              }
                                                                                                       } else {
                                                                                                       //        try{
                                                                                                       //            CryptUtil = new CryptUtil();
                                                                                                       //            CryptUtil.call(function(r){
                                                                                                       //                           RetArr = new Array();
                                                                                                       //                           RetArr = r.split("\t");
                                                                                                       //                           tmpparaData = "SrcName=" + RetArr[0];
                                                                                                       //                           tmpCookie = "DomainID="+ RetArr[1] + ";DiskType="+ RetArr[2] + ";User="+ RetArr[3] + ";Partition="+ RetArr[4] + ";WebServer="+ RetArr[5] + ";Agent="+ RetArr[6] + ";Option="+ RetArr[7] + ";Cowork="+ RetArr[8] + ";ShareUser="+ RetArr[9] + ";SharePath="+ RetArr[10] + ";StartPath="+ RetArr[11] + ";RealIP="+ RetArr[12];
                                                                                                       //
                                                                                                       //                           url = "http://npdocapp.koreanre.co.kr/webapp/custom_file_download2.jsp?CookieData="+tmpCookie+"&ParamData="+tmpparaData;
                                                                                                       //
                                                                                                       //                           window.open(url , "_blank", "location=no");
                                                                                                       //
                                                                                                       //                           if(GetlocalStorage("clickDrive") == 1){
                                                                                                       //                           setTimeout(function(){
                                                                                                       //                                      window.open(url , "_blank", "location=no");
                                                                                                       //                                      }, 500);
                                                                                                       //                           SetlocalStorage("clickDrive", 0);
                                                                                                       //                           beforeDriveName = nowDriveName;
                                                                                                       //                           }
                                                                                                       //                           }, "", parameter, GetlocalStorage("SiteID"));
                                                                                                       //        }catch(e){
                                                                                                       //            CryptUtil.call(function(r){
                                                                                                       //                           RetArr = new Array();
                                                                                                       //                           RetArr = r.split("\t");
                                                                                                       //                           tmpparaData = "SrcName=" + RetArr[0];
                                                                                                       //                           tmpCookie = "DomainID="+ RetArr[1] + ";DiskType="+ RetArr[2] + ";User="+ RetArr[3] + ";Partition="+ RetArr[4] + ";WebServer="+ RetArr[5] + ";Agent="+ RetArr[6] + ";Option="+ RetArr[7] + ";Cowork="+ RetArr[8] + ";ShareUser="+ RetArr[9] + ";SharePath="+ RetArr[10] + ";StartPath="+ RetArr[11] + ";RealIP="+ RetArr[12];
                                                                                                       //
                                                                                                       //                           url = "http://npdocapp.koreanre.co.kr/webapp/custom_file_download2.jsp?CookieData="+tmpCookie+"&ParamData="+tmpparaData;
                                                                                                       //
                                                                                                       //                           window.open(url , "_blank", "location=no");
                                                                                                       //
                                                                                                       //                           if(GetlocalStorage("clickDrive") == 1 && beforeDriveName != nowDriveName || beforeDriveName == "none"){
                                                                                                       //                           setTimeout(function(){
                                                                                                       //                                      window.open(url , "_blank", "location=no");
                                                                                                       //                                      }, 500);
                                                                                                       //                           SetlocalStorage("clickDrive", 0);
                                                                                                       //                           beforeDriveName = nowDriveName;
                                                                                                       //                           }
                                                                                                       //                           }, "", parameter, GetlocalStorage("SiteID"));
                                                                                                       //        }
                                                                                                       /*
                                                                                                        showUpDownProgressbar();
                                                                                                        downfile = setInterval(downloadprogress, 100);
                                                                                                        
                                                                                                        useProxy = GetlocalStorage("useProxy");
                                                                                                        updownmanager = new UpDownManager();
                                                                                                        updownmanager.download(SuccessFileOpen, failMsg, tmpDomainID, paraDiskType, User, tmpPartition, tmpWebServer, Agent, option, tmpOwner, tmpShareUser,
                                                                                                        tmpShareOwner, tmpStartPath, tmpOrgCode, srcName, tmpFileServer,useSSL,FileServerPort, "fileopen", siteid, attribute,tmpfilesize, tmpLocalpath, overwrite, offset, useProxy);
                                                                                                        */
                                                                                                       
                                                                                                       try{
                                                                                                       useProxy = GetlocalStorage("useProxy");
                                                                                                       updownmanager = new UpDownManager();
                                                                                                       updownmanager.download(SuccessFileOpen, failMsg, tmpDomainID, paraDiskType, User, tmpPartition, tmpWebServer, Agent, option, tmpOwner, tmpShareUser,
                                                                                                                              tmpShareOwner, tmpStartPath, tmpOrgCode, "backViewer", tmpFileServer,useSSL,FileServerPort, "fileopen", siteid, attribute,tmpfilesize, tmpLocalpath, overwrite, offset, useProxy, "no");
                                                                                                       }catch(e){
                                                                                                       //                                                                                                       alert('err = ' + e);
                                                                                                       }
                                                                                                       //              if(GetlocalStorage("clickDrive") == 1 && beforeDriveName != nowDriveName || beforeDriveName == "none"){
                                                                                                       //                  useProxy = GetlocalStorage("useProxy");
                                                                                                       //                  updownmanager = new UpDownManager();
                                                                                                       //                                                                                                       if(GetlocalStorage("clickDrive") == 1 && beforeDriveName != nowDriveName || beforeDriveName == "none" || pdfCheck == 1){
                                                                                                       //                                                                                                       setTimeout(function(){
                                                                                                       //                                                                                                                  updownmanager.download(SuccessFileOpen, failMsg, tmpDomainID, paraDiskType, User, tmpPartition, tmpWebServer, Agent, option, tmpOwner, tmpShareUser,tmpShareOwner, tmpStartPath, tmpOrgCode, srcName, tmpFileServer,useSSL,FileServerPort, "fileopen", siteid, attribute,tmpfilesize, tmpLocalpath, overwrite, offset, useProxy);
                                                                                                       //                                                                                                                  }, 500);
                                                                                                       //                                                                                                       SetlocalStorage("clickDrive", 0);
                                                                                                       //                                                                                                       beforeDriveName = nowDriveName;
                                                                                                       //                                                                                                       pdfCheck = 0;
                                                                                                       //                                                                                                       }
                                                                                                       
                                                                                                       }
                                                                                                       
                                                                                                       pdfCheck = 1;
                                                                                                       
                                                                                                       
                                                                                                       
                                                                                                       //    useProxy = GetlocalStorage("useProxy");
                                                                                                       //	updownmanager = new UpDownManager();
                                                                                                       //	updownmanager.download(SuccessFileOpen, failMsg, tmpDomainID, paraDiskType, User, tmpPartition, tmpWebServer, Agent, option, tmpOwner, tmpShareUser,
                                                                                                       //			tmpShareOwner, tmpStartPath, tmpOrgCode, srcName, tmpFileServer,useSSL,FileServerPort, "fileopen", siteid, attribute,tmpfilesize, tmpLocalpath, overwrite, offset, useProxy);
                                                                                                       }catch(e){
                                                                                                       navigator.notification.alert("열려있는 문서가 없습니다. \n" + e, function(){}, "", "확인");
                                                                                                       return;
                                                                                                       }
                                                                                                       }
