///////////////////////////////// LOCAL /////////////////////////////////////////////////////////////////////////////////
var fileSystemEntry;

/* 2016.03.10 수정 - 송낙규
//function downlocalFolerDrive(){
 * 기존 getLocalList() -> initLocal() -> downlocalFolderDrive() 절차 축소
 * getLocalList()와 initLocal() function은 제거
 */
function getLocalList() {
    window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, onSuccess, null);
}

/* Local Drive 가져오기
 * downlocalFolerDrive() -> onSuccess()
 */
function onSuccess(fileSystem) {
	setTimeout(function() {$('#explorer_lang_title').text(explorer_lang_title_local);}, 1);
	$('#work_lang_title').text(explorer_lang_title_local);
	$("#currentFolder").text("Local");
    $('#multipleBtnImg').css('display', 'block');
    $('#sortBtn_modal').css('display', 'table-cell');
	nowPage = "local";

	fileSystemEntry = fileSystem.root;
    tmpLocalRootPath = fileSystemEntry.toURL().substring("file://".length);
    path = tmpLocalRootPath+ECMFolder;
    
    fileSystemEntry.getDirectory("/Documents", {create:true, exclusive: false}, CreateRootFolder, failMsg);
}

/* ClouDoc root폴더(/ECM) 생성
 * downlocalFolerDrive() -> onSuccess() -> CreateRootFolder()
 */
function CreateRootFolder(entry) {
    tmpLocalRootPath = entry.toURL().substring("file://".length);
	rootpath = "/ECM";
    subrootpath = ECMFolder;
    UserFolder = subrootpath + "/" + User;
    
	entry.getDirectory(rootpath, {create:true, exclusive: false}, function() {
		entry.getDirectory(subrootpath, {create:true, exclusive: false}, function(){entry.getDirectory(UserFolder, {create:true, exclusive: false},function(){downLocalFolder("local_tree_0",'','')},failMsg)}
		, failMsg)}
	, failMsg);
}

//Local 목록 가져오기
/*function getLocalList() {
	initLocal();
}*/

/* local file목록 붙이기
 * getLocalList() -> initLocal()
 */
/*function initLocal() {
	$('#explorer_lang_title').text(explorer_lang_title_local);
	$('#work_lang_title').text(explorer_lang_title_local);
	$("#currentFolder").text("Local");
	nowPage = "local";

	$("#localList li").remove();
	treeid = "local_tree_0";
	$('#localList').append("<li class='drive'><div id='drive_image' onclick=\"downlocalFolerDrive()\"><img src='img/server.png'><span></span></div><div id='drive_info' onclick=\"downlocalFolerDrive()\"><div id='drive_info_name'>"+ "Local Storage"+ "</div><span></span></div></li>");
}*/

// Local 폴더 들어가기
function downLocalFolder(treeid, foldername, localpath) {
	tmpLocalTreeID = treeid;
	path = tmpLocalRootPath + ECMFolder + "/" + User;
	tmpLocalUserPath = "";
	if("" != foldername) {
		tmpLocalUserPath = localpath + "/" + foldername;
	}
    
	path = path + tmpLocalUserPath;

	var directoryReader = new DirectoryReader(path);
	directoryReader.readEntries(successList, failMsg);
}

// 로컬 파일 목록 재구성
var FolderArray = new Array();
var FolderPathArray = new Array();
var TreeIdArray = new Array();
function successList(entries) {
	$('#localList li').remove();

	currentFolder = tmpLocalUserPath.substring(tmpLocalUserPath.lastIndexOf("/")+1);
	if(currentFolder == "")	$("#currentFolder").text("Local");
	else					$("#currentFolder").text(currentFolder);

	var i;
	entries.sort();
	tmpFoderLength = entries.length;
    var e_fullpath;
    
	for(i=0; i<entries.length; i++) {
		treeid = tmpLocalTreeID+"_"+i;

		if(entries[i].isDirectory) {
            
            entries[i] = new Entry(entries[i].isFile, entries[i].isDirectory, entries[i].name, entries[i].fullPath, entries[i].fileSystem, entries[i].nativeURL);

			FolderArray.push(entries[i].name);
			FolderPathArray.push(entries[i].fullPath);
			TreeIdArray.push(treeid);
			entries[i].getMetadata(successFolderList, "");
		}
	}

	for(i=0; i<entries.length; i++) {
        
//        if(!entries[i].isDirectory)
//            xfile = entries[i].name.substring(entries[i].name.lastIndexOf(".") + 1);
        if(!entries[i].isDirectory){
            xfile = entries[i].name.substring(entries[i].name.lastIndexOf(".") + 1);
            xfile = xfile.toLowerCase();
            xfile = get_fileicon(xfile);
            

            entries[i].fullPath = tmpLocalRootPath + ECMFolder+ "/" + User + tmpLocalUserPath + "/" + entries[i].name;
            entries[i] = new FileEntry(entries[i].name, entries[i].fullPath, entries[i].fileSystem, entries[i].nativeURL);
        
            $("#local_list").append("<li class='filelist'><input type='checkbox' class='abs listcheckbox' value='"+entries[i].fullPath+"'/><img src='./img/icon/"+xfile+".png' class='abs fileimg'><div class='fileclick' onclick=\"openFile('"+entries[i].fullPath+"', '"+"Local"+"')\" ><span> "+entries[i].name+"</span><br><span class='subinfo'>"+"2888KB"+", &nbsp;&nbsp;"+"2011-11-08"+"</span></div></li>");
        
            entries[i].file(successFileList, "");
        }
	}
}

/* Local 폴더 붙이기
 * successList() -> successFolderList()
 */
function successFolderList(mFolder) {
	if(FolderArray.length != 0) {
		lastModDate = date_format(mFolder.modificationTime);
		tmpfolderfullpath = FolderPathArray[0];
		tmpfoldername = FolderArray[0];
		treeid = TreeIdArray[0];
		FolderArray.shift();
		FolderPathArray.shift();
		TreeIdArray.shift();

		$('#localList').append("<li class='folder'><div id='file_image' onclick=\"downLocalFolder('"+treeid+"', '"+tmpfoldername+"', '"+tmpLocalUserPath+"')\"><img src='img/folder.png'></div><div id='file_info' onclick=\"downLocalFolder('"+treeid+"', '"+tmpfoldername+"', '"+tmpLocalUserPath+"')\"><div id='file_info_name'>"+ tmpfoldername+ "</div><div id='file_info_date'>"+ lastModDate+ "</div></div><div class='file_func'><a href='#fileFuncModal' onclick=\"openFileFuncDialog('"+ tmpfoldername+ "')\"><img src='img/function.png'></a></div><div class='file_select'><input type='checkbox' id='"+ tmpfoldername+"' class='button-settings' value='"+ tmpfolderfullpath+"'/><label for='"+ tmpfoldername+"' onclick=\"li_select('"+ tmpfoldername+"')\"></label></div></li>");
    }
}

/* Local 파일 붙이기
 * successList() -> successFileList()
 */
function successFileList(file) {
	mod = new Date(file.lastModifiedDate);
	lastModDate = date_format(mod);

	xfile = file.name.substring(file.name.lastIndexOf(".")+1);
	xfile = xfile.toLowerCase();
	xfile = get_fileicon(xfile);
    xfileimg = "img/icon/" + xfile + ".png";
    
	fs = size_format(file.size);
    
    file.fullPath = tmpLocalRootPath + ECMFolder+ "/" + User + tmpLocalUserPath + "/" + file.name;
	$('#localList').append("<li class='file'><div id='file_image' onclick=\"openFile('"+file.fullPath+"', '"+"Local"+"')\"><img src='"+ xfileimg+ "'></div><div id='file_info' onclick=\"openFile('"+ file.fullPath+"', '"+"Local"+"')\"><div id='file_info_name'>"+ file.name+ "</div><div id='file_info_date'>"+ lastModDate+ "</div></div><div class='file_func'><a href='#fileFuncModal' onclick=\"openFileFuncDialog('"+ file.name+ "')\"><img src='img/function.png'></a></div><div class='file_select'><input type='checkbox' id='"+ file.name+"' class='button-settings' value='"+ file.fullPath+"'/><label for='"+ file.name+"' onclick=\"li_select('"+ file.name+"')\"></label></div></li>");
}

/* 폴더/파일 날짜 형식 변경
 * successList() -> successFolderList()/successFileList() -> date_format()
 */
function date_format(mdate) {
	var d  = mdate.getDate();
	var day = (d < 10) ? '0' + d : d;
	var m = mdate.getMonth() + 1;
	var month = (m < 10) ? '0' + m : m;
	var yy = mdate.getYear();
	var year = (yy < 1000) ? yy + 1900 : yy;
	var hours = mdate.getHours();
	var m_mm = mdate.getMinutes();
	var minutes = (m_mm < 10) ? '0' + m_mm : m_mm;
	var msc = mdate.getSeconds();
	var seconds = (msc < 10) ? '0' + msc : msc;
	var dateFormat = year + "-" + month + "-" + day + " " + hours + ":" + minutes + ":"+seconds;
   
	return dateFormat;
}

/* 폴더/파일 크기 형식 변경
 * successList() -> successFolderList()/successFileList() -> size_format()
 */
// 파일 크기 형식 변경
function size_format(fileSize) {
    if ( fileSize >= 1073741824 )
    {
        fileSize = number_format(fileSize / 1073741824, 0, '.', '') + " GB";
    }
    else
    {
        if ( fileSize >= 1048576 )
        {
            fileSize = number_format(fileSize / 1048576, 0, '.', '') + " MB";
        }
        else
        {
            if ( fileSize >= 1024 )
                fileSize = number_format(fileSize / 1024, 0, '.', '') + " KB";
            else
                fileSize = number_format(fileSize / 1024, 2, '.', '') + " KB";
        }
    }
    
    return fileSize;
}

/* 폴더/파일 크기 변경
 * successList() -> successFolderList()/successFileList() -> size_format() -> number_format()
 */
function number_format(number, decimals, dec_point, thousands_sep) {
	var n = number, c = isNaN(decimals = Math.abs(decimals)) ? 2 : decimals;
	var d = dec_point == undefined ? "," : dec_point;
	var t = thousands_sep == undefined ? "." : thousands_sep, s = n < 0 ? "-" : "";
	var i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "", j = (j = i.length) > 3 ? j % 3 : 0;

	return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
} 

// 로컬 폴더 내에서 상위폴더로 이동
function upLocalFolder() {
    if(multipleFlag == "true" && copyFlag != "true" && moveFlag != "true"){
        singleMode();
        multipleFlag = "false";
    }
    
	if(tmpLocalTreeID == "local_tree_0") return;

	tmpLocalTreeID = tmpLocalTreeID.substring(0, (tmpLocalTreeID.lastIndexOf("_")));

 	path = tmpLocalRootPath+ECMFolder+ "/" + User;
 	tmpLocalUserPath = tmpLocalUserPath.substring(0,(tmpLocalUserPath.lastIndexOf("/")));
 	path = path + tmpLocalUserPath;

 	var directoryReader = new DirectoryReader(path);
 	directoryReader.readEntries(successList,failMsg);
}

// 로컬에서 새폴더 생성
function newLocalFolder(foldername) {
	path = "Documents/" + ECMFolder + "/" + User + tmpLocalUserPath + "/" + foldername;
    path2 = "Documents/" + ECMFolder + "/" + User;
    fileSystemEntry.getDirectory(path2, {create: true}, function(parent) {
                                 parent.getParent(function(retval) {
                                                  }, failMsg);
                                 }, failMsg);
    
    
    try{
	fileSystemEntry.getDirectory(path, {create: true}, function(parent) {
                                 alert('1');
		parent.getParent(function(retval) {
                         retval.fullPath = tmpLocalRootPath + ECMFolder + "/" + User + tmpLocalUserPath;
			var directoryReader = new DirectoryReader(retval.fullPath);
			directoryReader.readEntries(successList, failMsg);
		}, failMsg);
	}, failMsg);
    }catch(e){
        alert('err = ' + e);
    }
}

// Local에서 Local로 파일 복사
function LocalCopy() {
	path = "Documents/" + ECMFolder + "/" + User + tmpLocalUserPath;
    
    var tmppath = tmpLocalRootPath + ECMFolder+ "/" + User + tmpLocalUserPath;
    
	if(tmpCheckedList.length > 0) {
		// 작업 원본폴더와 목적폴더가 같은 경우 작업 취소
		samePath= "file://"+ path;
		if(samePath == tmpCheckedList) {
			navigator.notification.alert(lang_alert_same_dir, null, 'Local', 'OK');
			return;
		}
        
		tmpnameArr = path.split("/");
		tmpname = tmpnameArr[tmpnameArr.length];
        
        token = tmpCheckedList[0].split("/");
        if(token[token.length-1])
            copypath = tmpCheckedList[0];
        else
            copypath = tmpLocalRootPath + tmpCheckedList[0].substring(11, tmpCheckedList[0].length);

		//copy path src
		window.resolveLocalFileSystemURI("file://"+copypath, function(directoryentry) {
			//paste path dst
			fileSystemEntry.getDirectory(path, {create:false, exclusive: false},
                                         function(directory) {
                                         directoryentry.copyTo(directory, tmpname,LocalCopy, failMsg);
                                         }, failMsg)}, failMsg);
        
        tmpCheckedList.splice(0,1);
	}
	
	if(tmpCheckedList.length <= 0) {
		var directoryReader = new DirectoryReader(tmppath);
		directoryReader.readEntries(successList, failMsg);
	}
}

// Local에서 Local로 파일 이동
function LocalMove() {
    tmppath = tmpLocalRootPath + ECMFolder + "/" + User + tmpLocalUserPath;
	path = "Documents/" + ECMFolder + "/" + User + tmpLocalUserPath;

	if(tmpCheckedList.length > 0) {
        
        var token = tmpCheckedList[0].split("/");
        
        if(token[token.length-1])
            movepath = tmpCheckedList[0];
        else
            movepath = tmpLocalRootPath + tmpCheckedList[0].substring(11, tmpCheckedList[0].length);
        
        
        // 작업 원본폴더와 목적폴더가 같은 경우 작업 취소
		samePath= "file://"+ path;
		if(samePath == tmpCheckedList) {
			navigator.notification.alert(lang_alert_same_dir, null, 'Local', 'OK');
			return;
		}

		tmpnameArr = path.split("/");
		tmpname = tmpnameArr[tmpnameArr.length];

        //copy path
		window.resolveLocalFileSystemURI("file://"+movepath, function(directoryentry) {
			//paste path
			fileSystemEntry.getDirectory(path, {create:false, exclusive: false},
                                         function(directory) {
                                         directoryentry.moveTo(directory, tmpname, LocalMove, failMsg);
                                         }, failMsg)}, failMsg);
        tmpCheckedList.splice(0,1);
	}

	if(tmpCheckedList.length <= 0) {
		var directoryReader = new DirectoryReader(tmppath);
		directoryReader.readEntries(successList, failMsg);
	}
}

// 로컬 폴더/파일 이름변경
function LocalRename(filename) {
	path = tmpLocalRootPath+ECMFolder+ "/" + User+tmpLocalUserPath;

	window.resolveLocalFileSystemURI("file://"+path+"/"+filename,
                                     function(files) {
                                     if(files.name == "data") navigator.notification.alert(lang_alert_valid_folder_name_close, null, 'Explorer', 'OK');
                                     else navigator.notification.alert(lang_already_folder_exists, null, 'Explorer', 'OK');
                                     },
                                     function(){LocalRenameProcess(filename);});
}

/* 로컬 폴더/파일 이름변경 진행
 * LocalRename() -> LocalRenameProcess()
 */
function LocalRenameProcess(filename) {
    
    
    path = "/Documents" + "/" + ECMFolder + "/" + User + tmpLocalUserPath;
    var token = checked_list[0].value.split("/");
    
	
    if(token[token.length-1]){
        renamepath = checked_list[0].value;
    }
    else{
        renamepath = tmpLocalRootPath + ECMFolder + "/" + User + tmpLocalUserPath + "/" + token[token.length-2];
    }

	//copy path
	window.resolveLocalFileSystemURI("file://" + renamepath, function(directoryentry) {
		//paste path
		fileSystemEntry.getDirectory(path, {create:false, exclusive: false}, function(directory) {
			directoryentry.moveTo(directory, filename, function() {
                                  path = tmpLocalRootPath + ECMFolder + "/" + User + tmpLocalUserPath;
                                  var directoryReader = new DirectoryReader(path);
                                  directoryReader.readEntries(successList, failMsg);
                                  }, failMsg);
                                     }, failMsg)}, failMsg);
    checked_list.splice(0,1);
	
	closeRenameDialog();
}

// 로컬파일 삭제
function LocalDeleteFile() {
	path = tmpLocalRootPath+ECMFolder+ "/"+User+tmpLocalUserPath;
    
    if(checked_list.length > 0) {
        var token = checked_list[0].value.split("/");
        
        if(token[token.length-1]){
            deletePath = checked_list[0].value;
        }
        else{
            deletePath = path + "/" + token[token.length-2];
        }

		//copy path
		window.resolveLocalFileSystemURI("file://"+deletePath, function(directoryentry) {
			checked_list.splice(0, 1);
			//paste path
			if(directoryentry.isDirectory) {
				directoryentry.removeRecursively(LocalDeleteFile, failMsg);
			} else {
				directoryentry.remove(LocalDeleteFile, failMsg);
			}
		}, failMsg);
	}

	if(checked_list.length <= 0) {
		var directoryReader = new DirectoryReader(path);
		directoryReader.readEntries(successList, failMsg);
	}
	
	singleMode();
}

/* Server로부터 파일 다운로드
 * 기존 과정: checkConnection() -> downconfirmwifi() -> download()
 * 수정된 과정: checkConnection() -> download()
 */
function download(overwrite, offset){

    tmpLocalpath = tmpLocalRootPath + ECMFolder+ "/" + User + tmpLocalUserPath;
    if( tmpLocalpath == "/ECM/data" ) return;
    srcName = "";
    attribute = "";
    size = "";
    tmpAttributeArr = new Array();
    for ( i=0; i< tmpCheckedList.length ; i++)
    {
        if ( i==0 )
        {
            srcName =  (saveUserPath+"/"+tmpCheckedList[i]).replace("//", "/");
            tmpAttributeArr = tmpCheckedListAttribute[i].split("\t");
            attribute = tmpAttributeArr[0];
            size = tmpAttributeArr[1];
        }
        else
        {
            srcName =  srcName + "\t" + (saveUserPath+"/"+tmpCheckedList[i]).replace("//", "/");
            tmpAttributeArr = tmpCheckedListAttribute[i].split("\t");
            attribute = attribute + "\t" + tmpAttributeArr[0];
            size = size + "\t" + tmpAttributeArr[1];
        }
    }
    siteid = GetlocalStorage("SiteID");
    option = "";
    if(paraDiskType == "personal") option = "0x01";
    
    useSSL = GetlocalStorage("SSL");
    FileServerPort = "";
    if(useSSL == "yes") FileServerPort = GetlocalStorage("FileSSlPort");
    else FileServerPort = GetlocalStorage("FileHttpPort");
    Agent = GetlocalStorage("Platform");

    useProxy = GetlocalStorage("useProxy");
    // saveSharePath ∞° æ¯¿Ω √ﬂ∞° ø‰∏¡
    updownmanager = new UpDownManager();
    updownmanager.download(SuccessDownLoad, failMsg, tmpDomainID, paraDiskType, User, savePartition, tmpWebServer, Agent, option, saveOwner, saveShareUser,
                           saveShareOwner, saveStartPath, tmpOrgCode, srcName, saveFileServer,useSSL,FileServerPort, "download", siteid, attribute, size, tmpLocalpath, overwrite, offset, useProxy);
    
    srcName = "";
    attribute = "";
}

/* Server로부터 파일 다운로드 수행 결과
 * checkConnection() -> downconfirmwifi() -> download() -> SuccessDownLoad()
 */
function SuccessDownLoad(r)
{
    tmpdeviceutil = new DeviceUtil();
    if(r == "exists"){
        //alert(lang_already_folder_exists);
        tmpdeviceutil.alert(function(){},function(){},lang_already_folder_exists);
    }
    else if(r == "Notexistingpath"){
        //alert(lang_alert_not_exists_path);
        tmpdeviceutil.alert(function(){},function(){},lang_alert_not_exists_path);
    }
    else if(r == "Failed"){
        //alert(lang_alert_create_folder_fail);
        tmpdeviceutil.alert(function(){},function(){},lang_alert_create_folder_fail);
    }
    else if(r == "overwrite"){
        clearInterval(downfile);
        downfileoverwrite = setInterval(downloadprogress, 100);
        showUpDownProgressbar();
        tmpdeviceutil.confirm(ConfirmDownOverwrite,ConfirmDownOverwrite,lang_alert_overwrite);
        //		bAnswer  = confirm(lang_alert_overwrite);
        //		if(bAnswer  == true)
        //			download("yes", "no");
        //		else
        //			download("no", "no");
    }
    else if(r == "offset"){
        clearInterval(downfile);
        downfileoffset = setInterval(downloadprogress, 100);
        showUpDownProgressbar();
        tmpdeviceutil.confirm(confirmDownOffset,confirmDownOffset,lang_alert_offset);
        //		bAnswer  = confirm(lang_alert_offset);
        //		if(bAnswer  == true)
        //			download("no", "yes");
        //		else
        //			download("no", "no");
    }
    else if(r == "complete"){
        srcName = "";
        attribute = "";
        showToast(toast_lang_download);
    }
    else if(r != "complete")
        //alert(r);
        tmpdeviceutil.alert(function(){},function(){},r);
    
    tmpLoalpath = tmpLocalRootPath+ECMFolder+"/"+User+tmpLocalUserPath;
    directoryReader = new DirectoryReader(tmpLoalpath);
    directoryReader.readEntries(successList,failMsg);
    tmpCheckedList = new Array();
    tmpCheckedListAttribute = new Array();
    clearInterval(downfile);
    clearInterval(downfileoverwrite);
    clearInterval(downfileoffset);
}

/* 다운로드 진행상태
 * 기존 과정: checkConnection() -> downconfirmwifi() -> download() -> SuccessDownLoad() -> downloadprogress()
 * 수정된 과정: checkConnection() -> download() -> SuccessDownLoad() -> downloadprogress()
 */
function downloadprogress() {
	tmpdeviceutil = new DeviceUtil();
	tmpdeviceutil.progress(getsize, "", "download");
}

/* 다운로드 진행상태의 표시 파일크기
 * 기존 과정: checkConnection() -> downconfirmwifi() -> download() -> SuccessDownLoad() -> downloadprogress() -> getsize()
 * 수정된 과정: checkConnection() -> download() -> SuccessDownLoad() -> downloadprogress() -> getsize()
 */
function getsize(retval) {
	var ProgressnumCurrent = document.getElementById("ProgressnumCurrent");
	var IndicatorCurrent = document.getElementById("IndicatorCurrent");
	var progressnum = document.getElementById("progressnum");
	var indicator = document.getElementById("indicator");

	SizeArr = new Array();
	SizeArr = retval.split("\t");
	currentmaxprogress = SizeArr[0];
	currentactualprogress = SizeArr[1] * ($('#ProgressbarCurrent').width()/currentmaxprogress);
	maxprogress = SizeArr[2];
	actualprogress = SizeArr[3] * ($('#progressbar').width()/maxprogress);
	IndicatorCurrent.style.width=currentactualprogress + "px";

	var nowsize = size_format(SizeArr[1]);
	var nowFilesize = size_format(SizeArr[0]);
	var totalnowsize = size_format(SizeArr[3]);
	var totalFilesize = size_format(SizeArr[2]);

	ProgressnumCurrent.innerHTML = nowsize+"\t"+"/"+"\t"+nowFilesize;
	indicator.style.width=actualprogress + "px";
	progressnum.innerHTML = totalnowsize+"\t"+"/"+"\t"+totalFilesize;
}

function openFile(filepath, openflag) {
    path = tmpLocalRootPath +ECMFolder+ "/" + User;
    
	if(nowPage == "local") {
		prePath= path;
		path = tmpLocalRootPath +ECMFolder+ "/" + User;
		tmpname = filepath.replace(path, "");
		path= prePath;
	} else if(nowPage == "server") {
		path = tmpLocalRootPath +ECMFolder+ "/" + User;
		tmpname = filepath.replace(path, "");
	}

	srcPath = tmpname.substring(tmpname.lastIndexOf('/'));
	FileExtensionArr = new Array();
	FileExtensionArr = srcPath.split(".");
	extension = FileExtensionArr[1];
	viewer = GetlocalStorage("Officesuite");
	file_open = GetlocalStorage("file_open");

	if(extension == "doc" || extension == "docx" || extension == "ppt" || extension == "pptx"
		 || extension == "xls" || extension == "xlsx" || extension == "txt" || extension == "pdf") {
		if(file_open == "viewer" && viewer == "nonexistent") {
			alertMessage("not installed officesuite");
			return;
    	}
    }

	index = tmpname.lastIndexOf('.');
	extension = tmpname.substring(index + 1).toLowerCase();
	siteid = GetlocalStorage("SiteID");
	user = GetsessionStorage("UserID");
	if(extension == "secure") {
		crypt = new CryptUtil();
		destpath = tmpLocalRootPath + "/ECM/dcrypt_tmp" + tmpname.substring(0, index);
		crypt.decrypt(SuccessDecrypt, function(e){alert('Local file decrypt error!');}, siteid, user, filepath, destpath);
	} else {
		CallApp(filepath, openflag, extension, siteid, user,"");
	}
}

function SuccessDecrypt(destpath) {
	/*hideWaiting();*/
	tmpname = destpath.substring(destpath.lastIndexOf('/'));
	index = tmpname.lastIndexOf('.');
	extension = tmpname.substring(index + 1).toLowerCase();
	openflag = "Local";
	siteid = GetlocalStorage("SiteID");
	user = GetsessionStorage("UserID");
	CallApp(destpath, openflag, extension, siteid, user);
}









function CallApp(filepath, openflag, extension, siteid, user) {

	filepath = encodeURI(filepath);
//	tmpcallapp = new AppManager();
	if(extension == "mp4" || extension == "avi" || extension == "3gp" || extension == "mov") {
		flag = "video";
        window.open(filepath, "_blank", "location=no");
//		tmpcallapp.callapp("", "", filepath, extension, flag, openflag, siteid, user, "");
	} else if(extension == "mp3" || extension == "wma") {
		flag = "music";
        window.open(filepath, "_blank", "location=no");
//		tmpcallapp.callapp("", "", filepath, extension, flag, openflag, siteid, user, "");
	} else if(extension == "jpg" || extension == "gif" || extension == "png") {
		flag = "imgage";
        window.open(filepath, "_blank", "location=no");
//		tmpcallapp.callapp("", "", filepath, extension, flag, openflag, siteid, user, "");
	} else if(extension == "doc" || extension == "docx" || extension == "ppt" || extension == "pptx"
		|| extension == "xls" || extension == "xlsx" || extension == "txt" || extension == "pdf"
		|| extension == "hwp" || extension == "html") {
		//viewer = GetlocalStorage("Officesuite");
		file_open = GetlocalStorage("file_open");
//		if( file_open == "viewer" && viewer == "nonexistent" ) {
//			alert("not exist Officesuite");
//			return;
//		}
		flag = "document";
        window.open(filepath, "_blank", "location=no");
//		tmpcallapp.callapp(finishCallApp, "", filepath, extension, flag, openflag, siteid, user, file_open);
	} else {
		navigator.notification.alert(
				lang_alert_not_support_format,
				null,
				'Explorer',
				'OK'
		);
	}
}

function finishCallApp() {
	clearInterval(downfile);
	clearInterval(downfileoverwrite);
	clearInterval(downfileoffset);
}

// 사진 촬영 후 업로드
function CallCamera() {
    closeCameraDialog();
    //	entertainment = new Entertainment();
    //	entertainment.Photo(SuccessCamera,"");

    cameraFlag = "camera"; // gallery or camera
    
    navigator.camera.getPicture(SuccessCamera, onCameraFail, { quality: 75,
                                destinationType: Camera.DestinationType.FILE_URI});
    hiddenAll();
}

// 동영상 촬영 후 업로드
function CallVideo() {
    closeCameraDialog();
    //	entertainment = new Entertainment();
    //	entertainment.Video(SuccessCamera,"");
    cameraFlag = "camera"; // gallery or camera
    
    //    navigator.camera.getPicture(SuccessCamera, onCameraFail, { quality: 75,
    //                                destinationType: Camera.DestinationType.FILE_URI,
    //                                sourceType : Camera.PictureSourceType.PHOTOLIBRARY,
    //                                mediaType : Camera.MediaType.VIDEO});
    
    navigator.device.capture.captureVideo(captureSuccess, captureError, {limit:2});
    
    hiddenAll();
}

function GetGallery(){
    //   	entertainment = new Entertainment();
    //	entertainment.Gallery(SuccessCamera,"");
    cameraFlag = "gallery"; // gallery or camera
    navigator.camera.getPicture(SuccessCamera, onCameraFail, { quality: 75,
                                destinationType: Camera.DestinationType.FILE_URI,
                                sourceType : Camera.PictureSourceType.SAVEDPHOTOALBUM,
                                mediaType : Camera.MediaType.ALLMEDIA});
    hiddenAll();
}

function onSuccessCamera(imageURI){
    //alert(imageURI);
    //tmpdeviceutil = new DeviceUtil();
    //tmpdeviceutil.alert(function(){},function(){},imageURI);
	navigator.notification.alert(    
			imageURI,    
			null,      		     
			'Camera',            		    
			'OK'                  
			);

}

function onCameraFail(r){
    //alert("fail " +  r);
    //tmpdeviceutil = new DeviceUtil();
    //tmpdeviceutil.alert(function(){},function(){},"fail " +  r);
	navigator.notification.alert(    
			'Fail : '+ r,    
			null,      		     
			'Camera',            		    
			'OK'                  
			);
}

// 사진 업로드
function GetGalleryPhoto() {
    closeCameraDialog();
    cameraFlag = "gallery"; // gallery or camera
    navigator.camera.getPicture(SuccessCamera, onCameraFail, { quality: 75,
                                destinationType: Camera.DestinationType.FILE_URI,
                                sourceType : Camera.PictureSourceType.SAVEDPHOTOALBUM,
                                mediaType : Camera.MediaType.ALLMEDIA});
    hiddenAll();
}

// 동영상 업로드
function GetGalleryVideo() {
    closeCameraDialog();
    cameraFlag = "gallery"; // gallery or camera
    navigator.camera.getPicture(SuccessCamera, onCameraFail, { quality: 75,
                                destinationType: Camera.DestinationType.FILE_URI,
                                sourceType : Camera.PictureSourceType.SAVEDPHOTOALBUM,
                                mediaType : Camera.MediaType.ALLMEDIA});
    hiddenAll();
}

function SuccessCamera(retV) {
    if(retV.indexOf("file://localhost/") != -1){
        retV = retV.replace("file://localhost/", "/");
    }
    if(retV.indexOf("file:///") != -1){
        retV = retV.replace("file:///", "/");
    }
    if(nowPage == "server"){
        attribute = "0";
        siteid = GetlocalStorage("SiteID");
        Agent = GetlocalStorage("Platform");
        User = GetsessionStorage("UserID");
        overwrite = "";
        offset = "";
        option = "";
        if(paraDiskType == "personal") option = "0x01";
        //upfile = setInterval(uploadprogress, 100);
        //showUpDownProgressbar();
        
        useSSL = GetlocalStorage("SSL");
        FileServerPort = "";
        if(useSSL == "yes") FileServerPort = GetlocalStorage("FileSSlPort");
        else FileServerPort = GetlocalStorage("FileHttpPort");
        
        updownmanager = new UpDownManager();
        updownmanager.upload(SuccessUpload, "", tmpDomainID, paraDiskType, User, tmpPartition, tmpWebServer, Agent, option, tmpOwner, tmpShareUser,
                             tmpShareOwner, tmpStartPath, tmpOrgCode, tmpUserPath, tmpFileServer, useSSL, FileServerPort, siteid, retV, overwrite, offset);
    }
    else{
        tmpnameArr = retV.split("/");
        tmpname = tmpnameArr[tmpnameArr.length-1];
        path = tmpLocalRootPath+"/"+ECMFolder+ "/" + User+tmpLocalUserPath;
        
        entertainment = new Entertainment();
        entertainment.Gallery(GetLocalImg,"", retV, path, tmpname, cameraFlag);
    }
}

function GetLocalImg(r){
    tmpLoalpath = tmpLocalRootPath + ECMFolder+ "/" + User+tmpLocalUserPath;
	directoryReader = new DirectoryReader(tmpLoalpath);
	directoryReader.readEntries(successList,failMsg);
}

// capture callback
function captureSuccess(mediaFiles) {
    var i, path, len;
    for (i = 0, len = mediaFiles.length; i < len; i += 1) {
        path = mediaFiles[i].fullPath;
        // do something interesting with the file
    }
    SuccessCamera(path);
};

// capture error callback
function captureError(error) {
    navigator.notification.alert('Error code: ' + error.code, null, 'Capture Error');
};

//Server에서 Local로 파일 복사/이동
//var downloadflag = "";
function checkConnection(flag) {
	//downloadflag = flag;
	var networkState = navigator.network.connection.type;
	var states = {};
	states[Connection.WIFI] = 'WiFi';

	/* 2016.02.11 수정
	 * 연결망 상관없이 다운로드 진행
	 */
	/* 기존 소스
	if(flag == "download" || flag == "fileopen") {
		if(states[networkState] == "WiFi" || GetlocalStorage("Use3GDown") == "yes") {
			if(flag == "download")
				download("","");
			else
				fileopen("","");
		} else
			downconfirmwifi();
	} else {
		if(states[networkState] == "WiFi" || GetlocalStorage("Use3GUp") == "yes")
			upload("","");
		else {
			navigator.notification.confirm(
					lang_confrim_wifi,
					upconfirmwifi,
					'Explorer',
					'No,Yes'
			);
		}
	}
	*/
	
	// 수정 소스
	if(flag == "download")		download("", "");
	else if(flag == "fileopen")	fileopen("", "");
	else						upload("", "");
}

/* 파일 다운로드
 * checkConnection() -> downconfirmwifi()
 */

/* Wifi에 연결과 상관없이 Up/Download 진행
 * downconfirmwifi(), upconfirmwifi() 삭제 - 2016.02.11
 */
/*function downconfirmwifi() {
	if(downloadflag == "download")
		download("","");
	else
		fileopen("","");
}

function upconfirmwifi(value) {
	if(value == "2") {
		SetlocalStorage("Use3GUp", "yes");
		upload("","");
	}
}*/

/* 덮어쓰기
 * checkConnection() -> downconfirmwifi() -> download() -> SuccessDownLoad() -> ConfirmDownOverwrite()
 */
function ConfirmDownOverwrite(value) {
	downfile = setInterval(downloadprogress, 100);
	showUpDownProgressbar();

	if(value == "2")	download("yes", "no");
	else				download("no", "no");
}

/* 
 * checkConnection() -> downconfirmwifi() -> download() -> SuccessDownLoad() -> confirmDownOffset()
 */
function confirmDownOffset(value) {
	downfile = setInterval(downloadprogress, 100);
	showUpDownProgressbar();
	
	if(value == "2")	download("no", "yes");
    else				download("no", "no");
}

// 수행작업 실패시 에러메시지
function failMsg(error) {
	if(error.code == 1) {
		navigator.notification.alert(
				lang_alert_not_found_err,
				null,
				'Explorer',
				'OK'
		);
	} else if(error.code == 2) {
		navigator.notification.alert(
				lang_alert_security_err,
				null,
				'Explorer',
				'OK'
		);
	} else if(error.code == 3) {
		navigator.notification.alert(
				lang_alert_abort_err,
				null,
				'Explorer',
				'OK'
		);
	} else if(error.code == 4) {
		navigator.notification.alert(
				lang_alert_not_readable_err,
				null,
				'Explorer',
				'OK'
		);
	} else if(error.code == 5) {
		navigator.notification.alert(
				lang_alert_encoding_err,
				null,
				'Explorer',
				'OK'
		);
	} else if(error.code == 6) {
		navigator.notification.alert(
				lang_alert_no_modification_allowed_err,
				null,
				'Explorer',
				'OK'
		);
	} else if(error.code == 7) {
		navigator.notification.alert(
				lang_alert_invalid_state_err,
				null,
				'Explorer',
				'OK'
		);
	} else if(error.code == 8) {
		navigator.notification.alert(
				lang_alert_syntax_err,
				null,
				'Explorer',
				'OK'
		);
	} else if(error.code == 9) {
		navigator.notification.alert(
				lang_alert_invalid_modification_err,
				null,
				'Explorer',
				'OK'
		);
	} else if(error.code == 10) {
		navigator.notification.alert(
				lang_alert_quota_exceeded_err,
				null,
				'Explorer',
				'OK'
		);
	} else if(error.code == 11) {
		navigator.notification.alert(
				lang_alert_type_mismatch_err,
				null,
				'Explorer',
				'OK'
		);
	} else if(error.code == 12) {
		navigator.notification.alert(
				lang_alert_path_exists_err,
				null,     		     
				'Explorer',
				'OK'
		);
	}
}
