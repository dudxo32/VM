var toast_lang_dataUse = "";

/**********		propertiesForm		**********/
// 등록정보 기본값 설정
function getProperties() {
	$('#settingForm').fadeOut(500);
	$('#propertiesForm').fadeIn(500);
	
	tmpAgent = GetlocalStorage("Platform");
	tmpDeviceID = GetlocalStorage("DeviceID");
	tmpServerIP= GetlocalStorage("webserver");
	tmpServerPort= GetlocalStorage("port");
	tmpUserID= GetlocalStorage("id");
	
	if(tmpAgent == "11")		tmpAgent= "IPhone";
	else if(tmpAgent == "12")	tmpAgent= "AndroidPhone";
	else if(tmpAgent == "13")	tmpAgent= "Windows";
	else 						tmpAgent= "Tablet";
	
	tmpDeviceID1= tmpDeviceID.substr(0, 25);
    tmpDeviceID2= tmpDeviceID.substr(25);
    tmpDeviceID= tmpDeviceID1 + " " + tmpDeviceID2;
    
	$('#devInfo_id').text(tmpDeviceID);
	$('#devInfo_model').text(tmpAgent);
	$('#serInfo_ip').text(tmpServerIP);
	$('#serInfo_port').text(tmpServerPort);
	$('#userInfo_id').text(tmpUserID);
}

function exitPropertiesForm() {
	$('#propertiesForm').fadeOut(500);
	$('#settingForm').fadeIn(500);
}

/**********		dataSettingForm		**********/
//데이터 사용여부 불러오기
function loadDataUse() {
	$('#settingForm').fadeOut(500);
	$('#dataSettingForm').fadeIn(500);

	var dataSetting = document.getElementsByName('onoffswitch');
	var useData = GetlocalStorage('useData');

	if(useData == "true")	dataSetting[0].checked = true;
	else					dataSetting[0].check = false;
}

// 데이터 사용여부 저장
function saveDataUse() {
	$('#dataSettingForm').fadeOut(500);
	$('#settingForm').fadeIn(500);

	var dataSetting = document.getElementsByName('onoffswitch');
	SetlocalStorage('useData', dataSetting[0].checked);

    showToast(toast_lang_dataUse);
}

// 터치 효과
function touchStart(obj){
    $(obj).css('background-color', '#e5f3fb');
}

function touchEnd(obj){
    $(obj).css('background-color', '#ffffff');
}