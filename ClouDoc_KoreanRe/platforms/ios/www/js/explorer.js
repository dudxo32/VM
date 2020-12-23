/* FUNCTION LIST
 * 
 * showBlank()
 * hideBlank()
 * openDocumentSelect()
 * closeDocumentSelect()
 * openMenu()
 * closeMenu()
 * openSortDialog()
 * closeSortDialog()
 * openFileFuncDialog(fileName)
 * closeFileFuncDialog()
 * openCameraDialog()
 * closeCameraDialog()
 * openNewFolderDialog()
 * closeNewFolderDialog()
 * openRenameDialog()
 * closeRenameDialog()
 * closeAll()
 * showToast()
 * 
 * selectServer()
 * selectLocal()
 * menuSelectServer()
 * menuSelectLocal()
 * changeToServer()
 * changeToServerForm()
 * changeToLocal()
 * serverDocumentBoxFunction()
 * localDocumentBoxFunction()
 * singleMode()
 * multipleMode()
 * workMode()
 * singleModeOn()
 * singleModeOff()
 * multipleAll()
 * multipleAllCancel()
 * fileSelect(object)
 * f_copy()
 * snip()
 * paste()
 * deleteFile()
 * ConfirmdeleteFile(value)
 * newFolderCreate()
 * rename()
 * showUpDownProgressbar()
 * hiddenUpDownProgressbar()
 * updownCancel()
 */
var explorer_lang_title_server = "";
var explorer_lang_title_local = "";
var toast_lang_move = "";
var toast_lang_copy = "";
var toast_lang_upload = "";
var toast_lang_download = "";
var toast_lang_delete = "";
var nowFunc = "none";

var detectTap = "";
var timer;
var mSelectedFiles = null;

// 블랭크 화면 보이기
function showBlank() {
    $('#blank').fadeIn('fast');
}

// 블랭크 화면 숨기기
function hideBlank() {
    $('#blank').fadeOut('fast');
}

// 문서함 변경 선택창 열기
function openDocumentSelect() {
	closeAll();
	$('#document_select').slideToggle("fast");

	$('.explorer_title').prop('onclick', null);
	$('.explorer_title').off('click', openDocumentSelect);
	$('.explorer_title').on('click', closeDocumentSelect);

	$('#blank').on('click', closeDocumentSelect);
	$('#blank').css('margin-top', $('#explorerTitle').height());
	showBlank();
}

// 문서함 변경 선택창 닫기
function closeDocumentSelect() {
	$('#document_select').slideToggle("fast");

	$('.explorer_title').off('click', closeDocumentSelect);
	$('.explorer_title').on('click', openDocumentSelect);

	$('#blank').off('click', closeDocumentSelect);
	$('#blank').css('margin-top', '0');
	hideBlank();
}

//좌측메뉴 열기
function openMenu() {
	closeAll();
//	$('#menu').animate({width: "toggle"}, 100);
    $('#menu').css('display', 'block');
    $('#menu').animate({'left': '0'}, 400);
	$('#blank').on('click', closeMenu);
	showBlank();
}

// 좌측메뉴 닫기
function closeMenu() {
//	$('#menu').animate({width: "toggle"}, 100);
    $('#menu').animate({'left': -$('#menu').width()}, 400, hideMenu);
	$('#blank').off('click', closeMenu);
	hideBlank();
}

function hideMenu(){
    $('#menu').css('display', 'none');
}

//파일 목록 정렬창 열기
function openSortDialog() {
	closeAll();
	$('#sortModal').css('display', 'block');
	
	$('#blank').on('click', closeSortDialog);
	showBlank();
}

// 파일 목록 정렬창 닫기
function closeSortDialog() {
	$('#sortModal').css('display', 'none');
	
	$('#blank').off('click', closeSortDialog);
	hideBlank();
}

// 단일파일 작업창 표시
function openFileFuncDialog(fileName) {
    closeAll();
    if(nowPage == "server")
        check_list = $("#explorerList input:checkbox");
    else if(nowPage == "local")
        check_list = $("#localList input:checkbox");
    
    fileName = fileName.indexOf("NetID_apostrophe") > -1?   fileName.replace(/NetID_apostrophe/gi, '\'') : fileName;
    for(i=0; i< check_list.length; i++) {
        var checkId = check_list[i].id.indexOf("NetID_apostrophe") > -1?   check_list[i].id.replace(/NetID_apostrophe/gi, '\'') : check_list[i].id;
        if(checkId == fileName)
            check_list[i].checked= true;
    }
    
    $('#fileFunc_lang_title').text(fileName);
    $('#fileFuncModal').css('display', 'block');
    
    // 파일명 길이 조절
    var gap = $('#maxFileNameWidth').width() * 0.9 - $('#fileFunc_lang_title').width();
    if(gap < 0) {
        if(fileName.lastIndexOf('.') < 0)
        {
            while(gap < 0) {
                fileName = fileName.substring(0, fileName.length-1);
                $('#fileFunc_lang_title').text(fileName);
                gap = $('#maxFileNameWidth').width() * 0.9 - $('#fileFunc_lang_title').width();
            }
            $('#fileFunc_lang_title').text(fileName + "...");
        }
        else
        {
            var extension = fileName.substring(fileName.lastIndexOf('.') + 1);
            var realFileName = fileName.substring(0, fileName.lastIndexOf('.'));
            var tempFileName = "";
            while(gap < 0) {
                realFileName = realFileName.substring(0, realFileName.length-1);
                tempFileName = realFileName + "." + extension;
                $('#fileFunc_lang_title').text(tempFileName);
                gap = $('#maxFileNameWidth').width() * 0.8 - $('#fileFunc_lang_title').width();
            }
            fileName = realFileName + "..." + fileName.substring(fileName.lastIndexOf('.')-3, fileName.lastIndexOf('.')) + "." + extension;
            $('#fileFunc_lang_title').text(fileName);
        }
    }
    
    $('#blank').on('click', closeFileFuncDialog);
    showBlank();
}

// 단일파일 작업창 숨기기
function closeFileFuncDialog() {
	$('#fileFuncModal').css('display', 'none');
	
	$('#blank').off('click', closeFileFuncDialog);
	hideBlank();
}

// 카메라 작업 창 열기
function openCameraDialog() {
	closeAll();
	$('#cameraUploadDialog').slideDown('fast');
	showBlank();
}

// 카메라 작업 창 닫기
function closeCameraDialog() {
	$('#cameraUploadDialog').slideUp('fast');
	hideBlank();
}

// 새폴더 생성 화면
function openNewFolderDialog() {
	closeAll();
	$('#newFolderForm').css('display', 'block');

	$('#blank').on('click', closeNewFolderDialog);
	showBlank();
}

// 새폴더 취소
function closeNewFolderDialog() {
	$('#newFolderName').val('');
	$('#newFolderForm').css('display', 'none');

	$('#blank').off('click', openNewFolderDialog);
	hideBlank();
}

//파일명 변경 화면
function openRenameDialog() {
	closeAll();

	if(nowPage == "server") {
		checked_list = $("#explorerList input:checkbox:checked");
		var tmpFilename = checked_list[0].value.indexOf("NetID_apostrophe") > -1?   checked_list[0].value.replace(/NetID_apostrophe/gi, '\'') : checked_list[0].value;
		var extension = "";
		if(tmpFilename.lastIndexOf('.') != -1) {
			index = tmpFilename.lastIndexOf('.');
			extension = tmpFilename.substring(index + 1).toLowerCase();
			reNameTmpFile = tmpFilename.split("." + extension);
			$('#renameName').val(reNameTmpFile[0]);
			$('#renameExtension').val(extension);
		} else {
			$('#renameName').val(checked_list[0].value);
			extension = "";
	    }
	} else if(nowPage == "local") {
		checked_list = $("#localList input:checkbox:checked");
		var tmpFilePath= checked_list[0].value.indexOf("NetID_apostrophe") > -1?   checked_list[0].value.replace(/NetID_apostrophe/gi, '\'') : checked_list[0].value;
		var tmpFilename = tmpFilePath.substring(tmpFilePath.lastIndexOf("/")+1);
		var extension = "";
		
		if(tmpFilename.lastIndexOf('.') != -1) {
			index= tmpFilename.lastIndexOf('.');
			extension= tmpFilename.substring(index+1).toLowerCase();
			// Server로부터 다운받아 암호화된 파일
			if(extension == "secure") {
				var split= tmpFilename.split('.');
				extension= split[split.length-2]+ "."+ split[split.length-1];
				extension= extension.toLowerCase();
				reNameTmpFile= tmpFilename.split("." + extension);
			}
			// 사용자에 의하여 생성된 파일
			else {
				reNameTmpFile = tmpFilename.split("." + extension);
			}
			$('#renameName').val(reNameTmpFile[0]);
			$('#renameExtension').val(extension);
		} else {
			var tempName = checked_list[0].value.substring(0, checked_list[0].value.lastIndexOf('/'));
            tempName = tempName.indexOf("NetID_apostrophe") > -1?   tempName.replace(/NetID_apostrophe/gi, '\'') : tempName;
			$('#renameName').val(tempName.substring(tempName.lastIndexOf('/')+1));
			extension = "";
	    }
	}
	
	$('#renameForm').css('display', 'block');
	$('#blank').on('click', closeRenameDialog);
	showBlank();
}

// 파일명 변경 취소
function closeRenameDialog() {
	$('#renameName').val('');
	$('#renameExtension').val('');
	
	$('#renameForm').css('display', 'none');

	$('#blank').off('click', closeRenameDialog);
	hideBlank();
	singleMode();
}

// 모든 창 닫기
function closeAll() {
	if($('#document_select').css('display') != "none")	closeDocumentSelect();
	if($('#menu').css('display') != "none")	closeMenu();
	if($('#sortModal').css('display') != "none")	closeSortDialog();
	if($('#fileFuncModal').css('display') != "none")	closeFileFuncDialog();
	if($('#cameraUploadDialog').css('display') != "none")	closeCameraDialog();
	if($('#newFolderForm').css('display') != "none")	closeNewFolderDialog();
	if($('#renameForm').css('display') != "none")	closeRenameDialog();
	if($('#explorerTitle_select').css('display') != "none")	singleMode();
}

// 토스트창 보여주기
function showToast(message) {
	$('#toastContent').text(message);
	$('#toast').fadeIn(1500);
	setTimeout(hideToast, 1000);
}

// 토스트창 감추기
function hideToast() {
	$('#toast').fadeOut(1500);
}

// explorerForm에서 서버문서함으로 변경 선택
function selectServer() {
	closeDocumentSelect();
	changeToServer();
}

//explorerForm에서 로컬문서함으로 변경 선택
function selectLocal() {
	closeDocumentSelect();
	changeToLocal();
}

// 좌측메뉴에서 서버문서함으로 변경 선택
function menuSelectServer() {
	closeMenu();
	changeToServer();
    SetlocalStorage("clickDrive", 1);
}

//좌측메뉴에서 로컬문서함으로 변경 선택
function menuSelectLocal() {
	closeMenu();
	changeToLocal();
}

/* 서버문서함으로 변경
 * selectServer() -> changeToServer()
 */
function changeToServer() {
	changeToServerForm();
	getDriveList();
}

function changeToServerForm() {
	$('#explorerList').css('display', 'block');
	$('#localList').css('display', 'none');
	
	$('#explorerTool_normal').css('display', 'table');
	$('#explorerTool_work').css('display', 'none');
}

/* 로컬문서함으로 변경
 * selectLocal() -> changeToLocal()
 */
function changeToLocal() {
	$('#explorerList').css('display', 'none');
	$('#localList').css('display', 'block');
	
	$('#explorerTool_normalOn').css('display', 'none');
	$('#explorerTool_normalOff').css('display', 'none');
	$('#explorerTool_work').css('display', 'flex');
	
	getLocalList();
}

// 좌측메뉴_서버문서함 여닫기
function serverDocumentBoxFunction() {
	serverDocumentBox= document.getElementById('serverDocumentBox');
	serverDocumentList= document.getElementById('serverDocumentList');
	var height= $(serverDocumentBox).height(); 
	
	if(serverDocumentList.style.display !== 'none') {
		serverDocumentList.style.display= 'none';
		serverDocumentBox.style.borderBottom= '2px solid #C6C6C6';
		serverDocumentBox.style.height= (height+2)+ 'px';
		$('#serverDocumentBox_btn img').attr('src', 'img/dnsortBtn.png');
	}
	else {
		serverDocumentList.style.display= 'block';
		serverDocumentBox.style.borderBottom= '1px solid #C6C6C6';
		serverDocumentBox.style.height= (height+1)+ 'px';
		$('#serverDocumentBox_btn img').attr('src', 'img/upsortBtn.png');
	}
}

//좌측메뉴_로컬문서함 여닫기
function localDocumentBoxFunction() {
	var localDocumentList = document.getElementById('localDocumentList');
	
	if(localDocumentList.style.display !== 'none') {
		localDocumentList.style.display= 'none';
		$('#localDocumentBox_btn img').attr('src', 'img/dnsortBtn.png');
	}
	else {
		localDocumentList.style.display= 'block';
		$('#localDocumentBox_btn img').attr('src', 'img/upsortBtn.png');
	}
}

// 단일파일 모드
function singleMode() {
	// 탐색기 상단
	$('#explorerTitle_normal').css('display', 'table-row');
	$('#explorerTitle_select').css('display', 'none');
	$('#explorerTitle_work').css('display', 'none');
	// 리스트 버튼
	$('.file_func').css('display', 'block');
	$('.file_select').css('display', 'none');
	$('.file_noneFunc').css('display', 'none');
	// 하단 툴바
	if(nowPage == "local") {
		$('#explorerTool_normalOn').css('display', 'none');
		$('#explorerTool_normalOff').css('display', 'none');
		$('#explorerTool_selected').css('display', 'none');
		$('#explorerTool_work').css('display', 'flex');
	} else {
		$('#explorerTool_normalOn').css('display', 'flex');
		$('#explorerTool_normalOff').css('display', 'none');
		$('#explorerTool_selected').css('display', 'none');
		$('#explorerTool_work').css('display', 'none');
	}
	
	// 파일 전체 선택이였을 경우 해제
	$('#multiple_lang_allSelcet').css('color', '#FFFFFF');
	
	multipleAllCancel();
}

// 다중파일 선택 모드
function multipleMode() {
	nowFunc = "multiple";
	multipleAllCancel();
	closeAll();

	// 탐색기 상단
	$('#explorerTitle_normal').css('display', 'none');
	$('#explorerTitle_select').css('display', 'table-row');
	$('#explorerTitle_work').css('display', 'none');
	// 리스트 버튼
	$('.file_func').css('display', 'none');
	$('.file_select').css('display', 'block');
	$('.file_noneFunc').css('display', 'none');
	// 하단 툴바
	$('#explorerTool_normalOn').css('display', 'none');
	$('#explorerTool_normalOff').css('display', 'none');
	$('#explorerTool_selected').css('display', 'flex');
	$('#explorerTool_work').css('display', 'none');
	
}

// 파일작업 모드
function workMode() {
	// 탐색기 상단
	$('#explorerTitle_normal').css('display', 'none');
	$('#explorerTitle_select').css('display', 'none');
	$('#explorerTitle_work').css('display', 'table-row');
	// 리스트 버튼
	$('.file_func').css('display', 'none');
	$('.file_select').css('display', 'none');
	$('.file_noneFunc').css('display', 'block');
	// 하단 툴바
	$('#explorerTool_normalOn').css('display', 'none');
	$('#explorerTool_normalOff').css('display', 'none');
	$('#explorerTool_selected').css('display', 'none');
	$('#explorerTool_work').css('display', 'flex');
}

// 단일파일 하단 툴바 On 
function singleModeOn() {
	$('#explorerTool_normalOn').css('display', 'flex')
	$('#explorerTool_normalOff').css('display', 'none')
}

// 단일파일 하단 툴바 Off
function singleModeOff() {
	$('#explorerTool_normalOn').css('display', 'none')
	$('#explorerTool_normalOff').css('display', 'flex')
}

// 파일 전체 선택
function multipleAll() {
	if(nowPage == "server") {
		check_list = $('#explorerList input:checkbox');
		checked_list= $('#explorerList input:checkbox:checked');
	} else if(nowPage == "local") {
		check_list = $('#localList input:checkbox');
		checked_list= $('#localList input:checkbox:checked');
	}
	
	if(check_list.length == checked_list.length) {
		for(i=0; i< check_list.length; i++) {
			check_list[i].checked= false;
			$('#multiple_lang_allSelcet').css('color', '#FFFFFF');
		}
	} else {
		for(i=0; i< check_list.length; i++) {
			check_list[i].checked= true;
			$('#multiple_lang_allSelcet').css('color', '#0A71A5');
		}
	}
}

// 파일 전체 선택 취소
function multipleAllCancel() {
	if(nowPage == "server")
		check_list = $("#explorerList input:checkbox");
	else if(nowPage == "local")
		check_list = $("#localList input:checkbox");
	
	for(i=0; i< check_list.length; i++) {
		check_list[i].checked= false;
	}
	
	$('#multiple_lang_allSelcet').css('color', '#FFFFFF');
	
}

// 전체 선택됬을 시 '전체'버튼 색변경
function fileSelect(object) {
    object = object.indexOf("NetID_apostrophe") > -1?   object.replace(/NetID_apostrophe/gi, '\'') : object;
    
	if(nowPage == "server") {
		check_list = $('#explorerList input:checkbox');
		checked_list= $('#explorerList input:checkbox:checked');
	} else if(nowPage == 'local') {
		check_list = $('#localList input:checkbox');
		checked_list= $('#localList input:checkbox:checked');
	}

	for(i=0; i < check_list.length; i++) {
        var checkID = check_list[i].id.indexOf("NetID_apostrophe") > -1?   check_list[i].id.replace(/NetID_apostrophe/gi, '\'') : check_list[i].id;
		if(checkID == object)
			target= check_list[i].checked;
	}

	if(target) {
		$('#multiple_lang_allSelcet').css('color', '#FFFFFF');
	} else {
		if(check_list.length == checked_list.length+1)
			$('#multiple_lang_allSelcet').css('color', '#0A71A5');
		else
			$('#multiple_lang_allSelcet').css('color', '#FFFFFF');
	}
}

// 파일 복사
function f_copy() {
    try{
	closeFileFuncDialog();
	tmpAction = "copy";

        
    
	if(nowPage == "server") {
		tmpFrom = "server";
		checked_list = $("#explorerList input:checkbox:checked");

		tmpCheckedList = new Array();
		tmpCheckedListAttribute = new Array();
		for(i=0; i < checked_list.length; i++) {
            var checkedVal = checked_list[i].value.indexOf("NetID_apostrophe") > -1?   checked_list[i].value.replace(/NetID_apostrophe/gi, '\'') : checked_list[i].value;
			tmpCheckedList.push(checkedVal);
			tmpCheckedListAttribute.push(checked_list[i].alt);	// size & type(folder/file)
		}

		saveFileServer = tmpFileServer;
		savePartition = tmpPartition;
		saveDiskType = tmpDiskType;
		saveOwner = tmpOwner;
		saveStartPath = tmpStartPath;
		saveUserPath = tmpUserPath;
		saveShareUser = tmpShareUser;
		saveShareOwner = tmpShareOwner;
		saveSharePath = tmpSharePath;
		
//		getDriveList();
	} else if ( nowPage == "local" ) {
        tmpFrom = "local";
        checked_list = $("#localList input:checkbox:checked");
        
        tmpCheckedList = new Array();
        for(i=0; i< checked_list.length; i++) {
            var checkedVal = checked_list[i].value.indexOf("NetID_apostrophe") > -1?   checked_list[i].value.replace(/NetID_apostrophe/gi, '\'') : checked_list[i].value;
            tmpCheckedList.push( checkedVal );
        }
        
		getLocalList();
	}
	
	workMode();
    }catch(e){
        alert('err = ' + e);
    }
}

// 파일 잘라내기
function snip() {
	closeFileFuncDialog();
	
	tmpAction = "snip";
	if(nowPage == "server") {
		tmpFrom = "server";
		checked_list = $("#explorerList input:checkbox:checked");

		tmpCheckedList = new Array();
		tmpCheckedListAttribute = new Array();
		for(i=0; i < checked_list.length; i++) {
            var checkedVal = checked_list[i].value.indexOf("NetID_apostrophe") > -1?   checked_list[i].value.replace(/NetID_apostrophe/gi, '\'') : checked_list[i].value;
			tmpCheckedList.push(checkedVal);
			tmpCheckedListAttribute.push(checked_list[i].alt);
		}

		saveFileServer = tmpFileServer;
		savePartition = tmpPartition;
		saveDiskType = tmpDiskType;
		saveOwner = tmpOwner;
		saveStartPath = tmpStartPath;
		saveUserPath = tmpUserPath;
		saveShareUser = tmpShareUser;
		saveShareOwner = tmpShareOwner;
		saveSharePath = tmpSharePath;
		
//		getDriveList();
	} else if(nowPage == "local") {
		tmpFrom = "local";
		checked_list = $("#localList input:checkbox:checked");

		tmpCheckedList = new Array();
		for(i=0; i < checked_list.length; i++) {
            var checkedVal = checked_list[i].value.indexOf("NetID_apostrophe") > -1?   checked_list[i].value.replace(/NetID_apostrophe/gi, '\'') : checked_list[i].value;
			tmpCheckedList.push(checkedVal);
		}
		
		getLocalList();
	}

	workMode();
}

// 복사/이동할 파일 붙이기
function paste() {
	if(tmpFrom == "server" && nowPage == "server") {
		if(tmpAction == "snip")	SeverMoveFile();
		else 					ServerCopyFile();
	} else if(tmpFrom == "server" && nowPage == "local") {
		if(tmpAction == "copy") {
			flag = "download";
			checkConnection("download");
		} else
			alert("Server에서 Local로 파일 이동은 불가능합니다.");
	} else if(tmpFrom == "local" && nowPage == "local") {
		if(tmpAction == "snip")	LocalMove();
		else					LocalCopy();
	} else if(tmpFrom == "local" && nowPage == "server") {
		if(tmpAction == "copy")
			checkConnection("upload");
		else
			alert("Server에서 Local로 파일 이동은 불가능합니다.");
	}
	
	showToast("복사/이동이 완료되었습니다.");
	singleMode();
}

// 파일 삭제
function deleteFile() {
	closeFileFuncDialog();
	
	if(nowPage == "server")		checked_list = $("#explorerList input:checkbox:checked");
	else if(nowPage == "local")	checked_list = $("#localList input:checkbox:checked");
	
	navigator.notification.confirm(/* lang_alert_delete, */'삭제하시겠습니까?', ConfirmdeleteFile, 'Explorer', ['No', 'Yes']);
}

// 파일 삭제 승인
function ConfirmdeleteFile(value) {
	if(value == "2") {
		if(nowPage == "server") {
			ServerDeleteFile();
		} else {
            LocalDeleteFile();
        }
    }
}

//새폴더 생성
function newFolderCreate() {
	var newfoldername = $('#newFolderName').val();
	
	// 폴더명이 비었을 경우 
	if(newfoldername == "") {
		navigator.notification.alert(lang_alert_valid_folder_name, "", 'Explorer', 'OK');
		return;
	}

	// 폴더명을 입력하였을 경우
	if(nowPage == "server")
		newServerFolder(newfoldername);
	else if (nowPage == "local")
		newLocalFolder(newfoldername);

	closeNewFolderDialog();
}

// 파일명 변경
function rename() {
    try{
	filename = $('#renameName').val();
	extension = $('#renameExtension').val();

	if(extension != "") {
        filename = filename + "." + extension;
        $('#renameExtension').val('');
        extension = "";
	}
	
	if(nowPage == "server")
		ServerRename(filename);
	else if ( nowPage == "local" )
		LocalRename(filename);
    }catch(e){
        alert('err = ' + e);
    }
}

//파일 다운로드 현황판 표시
function showUpDownProgressbar() {
	document.getElementById("IndicatorCurrent").style.width = "0px";
	document.getElementById("indicator").style.width = "0px";
	document.getElementById("ProgressnumCurrent").innerHTML = "0";
	document.getElementById("progressnum").innerHTML = "0";

	updown_progressbar = $('#updown_progressbar');

	updown_progressbar.show();
}

// 파일 다운로드 현황판 숨김
function hiddenUpDownProgressbar() {
	$('#updown_progressbar').hide();
}

// 파일 다운로드 취소
function updownCancel() {
	hiddenUpDownProgressbar();
	UpDownManager.cancel("", "");	
}

function resizeTextSize() {
    var x = document.getElementById("newFolderName");
    x.style.fontSize = (x.clientHeight * 0.5) + "px";
}

function resizeTextSize_rename() {
    var y = document.getElementById("renameName");
    y.style.fontSize = (y.clientHeight * 0.5) + "px";
}

/* 리스트 클릭시 색상 변환 */
function touchStart(obj) {
    detectTap = true; //@@
    timer = setTimeout(function(){
                       if ( $(obj).parent().prop("nodeName").toLowerCase() == "header" )
                       {
                       $(obj).find("img").css("background-color", "");
                       }
                       else
                       {
                       openTargetList = obj;
                       $(obj).css('background-color', '#FFFFFF');
                       }
                       
                       if ( detectTap )
                       {
                       selectMode(detectTap, obj);
                       }
                       }, 500);
    
    if ( $(obj).parent().prop("nodeName").toLowerCase() == "header" )
    {
        $(obj).find("img").css("background-color", "#E5F3FB");
    }
    else
    {
        if ( openTargetList != null )
        {
            $(openTargetList).css('background-color', '#FFFFFF');
            openTargetList = null;
        }
        $(obj).css('background-color', '#E5F3FB');
    }
}

/* 리스트 클릭 해제시 색상 복구 */
function touchEnd(obj) {
    if (timer)
        clearTimeout(timer); //@@
    
    if ( $(obj).parent().prop("nodeName").toLowerCase() == "header" )
    {
        $(obj).find("img").css("background-color", "");
    }
    else
    {
        openTargetList = obj;
        $(obj).css('background-color', '#FFFFFF');
    }
}

function touchMove(obj) {
    detectTap = false; //@@
    
    if ( $(obj).parent().prop("nodeName").toLowerCase() == "header" )
    {
        $(obj).find("img").css("background-color", "");
    }
    else
    {
        openTargetList = obj;
        $(obj).css('background-color', '#FFFFFF');
    }
}

// Select mode on/off
function selectMode(onOff, fileList) {
    if ( onOff ) // select mode on
    {
        $(".contents-list").addClass("select");
        $("header").addClass("select");
        $(".list-file").find("img:nth-child(4)").hide();
        $(".list-file").find("img:nth-child(" + ("bookmark" == nowPage? "6" : "recent" == nowPage? "4" : "5") + ")").show();
        
        if ( "select" == nowMode ) return;
        nowMode = "select";
        
        mSelectedFiles = new Object();
        if ( fileList ) {
            addSelectedFile(fileList);
        }
    }
    else // select mode off
    {
        $(".contents-list").removeClass("select");
        $("header").removeClass("select");
        $(".list-file").find("img:nth-child(4)").show();
        $(".list-file").find("img:nth-child(" + ("bookmark" == nowPage? "6" : "recent" == nowPage? "4" : "5") + ")").hide();
        
        nowMode = "none";
        
        clearSelectedFiles();
    }
}

function addSelectedFile(file, BMFileInfo) {
    if ( "list-file" != file.className ) file = file.closest(".list-file");
    
    var addButton = file.children["bookmark" == nowPage? 5 : "recent" == nowPage? 3 : 4];
    
    var fileInfo = file.dataset;

    if ( fileInfo.permission.indexOf('r') < 0 ) {
        navigator.notification.confirm("파일 열기 권한이 없습니다.", function(){}, "", ["확인"]);
        return;
    }
    
    if ( "list-unchecked" == addButton.className )
    {
        var path = "";
        addButton.className = "list-checked";
        
        var fileInfoPack = new Object();
        if ( "bookmark" == nowPage || "recent" == nowPage )
        {
            var infos = BMFileInfo.split("\t");
            path = infos[3] + infos[1];
            
            fileInfoPack.name = fileInfo.filename;
            fileInfoPack.size = infos[12];
            fileInfoPack.diskType = infos[3];
            fileInfoPack.partition = infos[4];
            fileInfoPack.option = infos[5];
            fileInfoPack.owner = infos[6];
            fileInfoPack.shareUser = infos[7];
            fileInfoPack.shareOwner = infos[8];
            fileInfoPack.startPath = infos[9];
            fileInfoPack.orgCode = infos[10];
            fileInfoPack.fileServer = infos[11];
            fileInfoPack.fullPath = infos[1];
        }
        else
        {
            path = paraDiskType + tmpUserPath + ("/" == tmpUserPath? "" : "/") + fileInfo.filename;
            
            fileInfoPack.name = fileInfo.filename;
            fileInfoPack.size = fileInfo.size;
            fileInfoPack.diskType = paraDiskType;
            fileInfoPack.partition = tmpPartition;
            fileInfoPack.option = option;
            fileInfoPack.owner = tmpOwner;
            fileInfoPack.shareUser = tmpShareUser;
            fileInfoPack.shareOwner = tmpShareOwner;
            fileInfoPack.startPath = tmpStartPath;
            fileInfoPack.orgCode = tmpOrgCode;
            fileInfoPack.fileServer = tmpFileServer;
            fileInfoPack.fullPath = tmpUserPath == "/" ? tmpUserPath + fileInfo.filename : tmpUserPath + "/" + fileInfo.filename;
        }
        
        mSelectedFiles[path] = fileInfoPack;
    }
    else
    {
        addButton.className = "list-unchecked";
        
        delete mSelectedFiles[path];
    }
}

function openMultiFile() {
    if(Object.keys(mSelectedFiles).length == 0)
    {
        navigator.notification.confirm("선택된 파일이 없습니다.", function(){}, "", ["확인"]);
        return;
    }
    
    var srcName = "";
    var size = "";
    var attribute = "";
    var disktype = "";
    var partition = "";
    var startpath = "";
    var owner = "";
    var option = "";
    var fileServer = "";
    
    for( var key in mSelectedFiles ) {
        srcName += srcName == ""?       mSelectedFiles[key].fullPath : "\t" + mSelectedFiles[key].fullPath;
        size += size == ""?             mSelectedFiles[key].size : "\t" + mSelectedFiles[key].size;
        attribute += attribute == ""?   "0" : "\t" + "0";
        disktype += disktype == ""? mSelectedFiles[key].diskType : "\t" + mSelectedFiles[key].diskType;
        partition += partition == ""? mSelectedFiles[key].partition : "\t" + mSelectedFiles[key].partition;
        startpath += startpath == ""? mSelectedFiles[key].startPath : "\t" + mSelectedFiles[key].startPath;
        owner += owner == ""? mSelectedFiles[key].owner : "\t" + mSelectedFiles[key].owner;
        option += option == ""? mSelectedFiles[key].option : "\t" + mSelectedFiles[key].option;
        fileServer = mSelectedFiles[key].fileServer;
    }
    
    var overwrite = "";
    var offset = "";
    tmpLocalpath = tmpLocalRootPath +"/ECM";
    siteid = GetlocalStorage("SiteID");
    Agent = GetlocalStorage("Platform");
    if(paraDiskType == "personal") option = "0x01";
    
    useSSL = GetlocalStorage("SSL");
    FileServerPort = "";
    if(useSSL == "yes") FileServerPort = GetlocalStorage("FileSSlPort");
    else FileServerPort = GetlocalStorage("FileHttpPort");
    
    // 다중 파일 열기 시 최근 문서에 추가
    for( var key in mSelectedFiles ) {
        var fileInfo = "file" + "\t" + mSelectedFiles[key].diskType + "\t" + mSelectedFiles[key].partition + "\t" + mSelectedFiles[key].option + "\t" + mSelectedFiles[key].owner + "\t" + tmpShareUser + "\t" + tmpShareOwner + "\t" + mSelectedFiles[key].startPath + "\t" + tmpOrgCode + "\t" + mSelectedFiles[key].fileServer + "\t" + mSelectedFiles[key].size;
        var path = mSelectedFiles[key].diskType + mSelectedFiles[key].fullPath ;
        
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
    }
    
    useProxy = GetlocalStorage("useProxy");
    updownmanager = new UpDownManager();
    updownmanager.download(SuccessFileOpen, failMsg, tmpDomainID, disktype, User, partition, tmpWebServer, Agent, option, owner, tmpShareUser,
                           tmpShareOwner, startpath, tmpOrgCode, srcName, fileServer,useSSL,FileServerPort, "fileopen", siteid, attribute,size, tmpLocalpath, overwrite, offset, useProxy, "no");
    
    selectMode(false);
}

function clearSelectedFiles() {
    mSelectedFiles = null;
    $(".list-checked").addClass("list-unchecked").removeClass("list-checked");
}

// 검색 입력칸 이벤트
function searchInput() {
    var inputDom = $(".contents-search input");
    if ( inputDom.val() == "" ) inputDom.css("background", "");
    else                        inputDom.css("background", "none");
    searchFile();
}

// 검색
function searchFile() {
    try{
    var labels = "";
    if ( nowPage == "server" )  labels = $(".list").show().find("label:nth-child(2)");
    else                        labels = $(".list").show().find("label:nth-child(2) > p:first-child");
        
    var target;
    for ( var index = 0; index < labels.length; index++ ) {
        target = $(labels[index]);
        if ( target.text().toLowerCase().indexOf($(".contents-search input").val().toLowerCase()) < 0 ) target.parents(".list").hide();
    }
    if ( $(".highlight").length > 0 )   labels.unhighlight();
    labels.highlight($(".contents-search input").val());
    }catch(e){
        alert('err = ' + e);
    }
}

// 환경설정 창
function settingDialogManager(way) {
    var dialog = $(".dialog-setting");
    if ( way == "open" )
    {
        if ( nowMode == "BMEdit" )  cancelEditMode(true);
        $(".contents-list").css("overflow-y", "scroll");
        $(".blank").on("click", function(){settingDialogManager("close");}).show();
        dialog.show();
        loadSettingInfo();
    }
    else
    {
        $(".contents-list").css("overflow-y", "scroll");
        $(".blank").off("click").hide();
        saveSettingInfo();
        dialog.hide();
    }
}

// 좌측메뉴 닫기
function closeLeftMenu(){
    var menu = $("nav");
    if ( menu.hasClass("openedMenu") ) leftMenuManager();
}

// 로그아웃 확인
function logoutConfirm() {
    try{
    navigator.notification.confirm("로그아웃 하시겠습니까?", logout, "", ["확인", "취소"]);
    }catch(e){
        alert('err = ' +e);
    }
}

function logout(button) {
    if(button == 1){
        SetlocalStorage("auto", "false");
        SetlocalStorage("autoPassword", "");
        
        localStorage.removeItem("UserID");
        localStorage.removeItem("AuthKey");
        
        AM = new AppManager();
        AM.auth_logout();
        AM.finishapp();
    } else {
        
    }
}

function loadSettingInfo() {
    var settingLists = $(".dialog-setting li");
        
    // Set version
    // Set user ID
    $(settingLists[1]).find("div:nth-child(2) label").text(GetlocalStorage("id"));
        
    // Set theme
    var themeColor = GetlocalStorage("theme") == null?  "Blue" : GetlocalStorage("theme");
    $(settingLists[2]).find("input[name=theme][value=" + themeColor + "]").prop("checked", "checked");
        
    // Set font size
    var fontSize = GetlocalStorage("fontSize") == null? "Middle" : GetlocalStorage("fontSize");
    $(settingLists[3]).find("input[name=font-size][value=" + fontSize + "]").prop("checked", "checked");
    
    // Set file show info
    var fileShowInfo = GetlocalStorage("fileShowInfo") == null? "hide" : GetlocalStorage("fileShowInfo");
    $(settingLists[4]).find("input[name=fileShowInfo][value=" + fileShowInfo + "]").prop("checked", "checked");
    
    // Set bookmark show path
    var BMShowPath = GetlocalStorage("BMShowPath") == null? "hide" : GetlocalStorage("BMShowPath");
    $(settingLists[5]).find("input[name=BMShowPath][value=" + BMShowPath + "]").prop("checked", "checked");
    
    // Set document preview option
    var documentPreview = GetlocalStorage("documentPreview") == null? "unuse" : GetlocalStorage("documentPreview");
    $(settingLists[6]).find("input[name=usePreview][value=" + documentPreview + "]").prop("checked", "checked");
    
}

function saveSettingInfo() {
    SetlocalStorage("theme", $(".dialog-setting input[name=theme]:checked").val());
    SetlocalStorage("fontSize", $(".dialog-setting input[name=font-size]:checked").val());
    SetlocalStorage("fileShowInfo", $(".dialog-setting input[name=fileShowInfo]:checked").val());
    SetlocalStorage("BMShowPath", $(".dialog-setting input[name=BMShowPath]:checked").val());
    SetlocalStorage("documentPreview", $(".dialog-setting input[name=usePreview]:checked").val());
}

function changeFontSize(current) {
    $("link[rel=stylesheet][href*=font]").attr("disabled", "disabled");
    $("link[href*=font" + current + "]").removeAttr("disabled");

//    var temp = $("link[rel=stylesheet][href*=font]");
//    for ( var i = 0; i < temp.length; i++ ) {
//        alert("[" + $(temp[i]).attr("disabled") + "]\n" + $(temp[i]).html());
//    }
}

function changeTheme(current) {
    $("link[rel=stylesheet][href*=theme]").attr("disabled", "disabled");
    $("link[href*=theme" + current + "]").removeAttr("disabled");
}

function changeBMShowPath(current) {
    if ( current == "show" )    $(".BM-list").addClass("BM-showPath");
    else                        $(".BM-list").removeClass("BM-showPath");
}

function changeFileShowInfo(current) {
    if ( current == "show" )    $(".list").addClass("showInfo");
    else                        $(".list").removeClass("showInfo");
}

// 경로 표시
function controlShowPath() {
    var pathCount = $("nav").is(":visible")?    3 : 4;
    var showPath = tmpUserPath.replace(/\//gi, " > ");
    showPath == " > "?  $("#NetID_currentFolder").text("") : $("#NetID_currentFolder").text(showPath);
    
    while ( $("#NetID_currentFolder").width() > ($("#NetID_explorerDir").width() * 0.65) ) {
        if ( $("#NetID_currentFolder").text().split(" > ").length > pathCount )
        {
            var paths = showPath.split(" > ");
            showPath = "";
            for ( var index = 2; index < paths.length; index++ ) {
                showPath += " > " + paths[index];
            }
            $("#NetID_currentFolder").text(showPath);
        }
        else
        {
            if ( $("#NetID_currentFolder").text().split(" > ").length < pathCount ) break;
            while ( $("#NetID_currentFolder").width() > ($("#NetID_explorerDir").width() * 0.65) ) {
                var paths = showPath.split(" > ");
                var parentPath = paths[1];
                if ( getByteLength(parentPath) >= 7 ) {
                    parentPath = parentPath.substring(0, parentPath.length - 1);
                    var currentPath = paths[2];
                    showPath = " > " + parentPath + " > " + currentPath;
                    if ( getByteLength(parentPath) <= 6 ) {
                        showPath = parentPath + "... > " + currentPath;
                        $("#NetID_currentFolder").text(showPath);
                        break;
                    }
                    $("#NetID_currentFolder").text(showPath);
                }
                else   break;
            }
            break;
        }
    }
}

                                       
                                       
/* 즐겨찾기 -> 탐색기 */
function restoreExplorerForm() {
    if ( nowPage == "server" ) return;
    nowPage = "server";
    $('nav > div:nth-child(4) > div.BM-selected').removeClass('BM-selected');
    $('.contents-title').show();
    $('.bookmark-title').hide();
    $('.recent-title').hide();
                                       
    cancelEditMode();
}

                                       // 특수문자 문자열로 변환
                                       function changeSpecialChar(str) {
                                       return str.replace(/\'/gi, "NetIDApostrophe");
                                                          }
                                                          
                                                          // 문자열 특수문자로 복원
                                                          function reChangeSpecialChar(str) {
                                                          return str.replace(/NetIDApostrophe/gi, "\\'");
                                                          }
                                       
                                                          function removeSpecialChar(str) {
                                                          return str.replace(/\`/gi, "\\`")
                                                          .replace(/\~/gi, "\\~")
                                                          .replace(/\!/gi, "\\!")
                                                          .replace(/\@/gi, "\\@")
                                                          .replace(/\#/gi, "\\#")
                                                          .replace(/\$/gi, "\\$")
                                                          .replace(/\%/gi, "\\%")
                                                          .replace(/\^/gi, "\\^")
                                                          .replace(/\&/gi, "\\&")
                                                          .replace(/\*/gi, "\\*")
                                                          .replace(/\(/gi, "\\(")
                                                                   .replace(/\)/gi, "\\)")
                                                          .replace(/\[/gi, "\\[")
                                                                      .replace(/\]/gi, "\\]")
                                                                      .replace(/\{/gi, "\\{")
                                                                      .replace(/\}/gi, "\\}")
                                                                      .replace(/\</gi, "\\<")
                                                                      .replace(/\>/gi, "\\>")
                                                                      .replace(/\./gi, "\\.")
                                                                      .replace(/\,/gi, "\\,")
                                                                      .replace(/\//gi, "\\/")
                                                                               .replace(/\?/gi, "\\?")
                                                                               .replace(/\;/gi, "\\;")
                                                                               .replace(/ /gi, "\\ ");
                                                                               }
