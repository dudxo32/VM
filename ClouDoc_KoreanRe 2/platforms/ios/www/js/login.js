/*		loginForm		*/
// 로그인 아이디 입력칸 클릭 시 focus on
function login_id_focus() {
	document.getElementById('login_id').focus();
}

// 로그인 비밀번호 입력칸 클릭 시 focus on
function login_pw_focus() {
    try{
	document.getElementById('login_pw').focus();
    }catch(e){
        alert('err = ' + e);
    }
}

// 서버정보를 변경하려 할 시
function changeServer() {
	var server= $('#login_server').text();
	
	if(server == null || server == "") {
		navigator.notification.confirm(login_alert_input_server, goSerInfoFormMsg, login_alert_title, 'Cancel, OK');
	} else {
		navigator.notification.confirm(login_alert_change_server, goSerInfoFormMsg, login_alert_title, 'Cancel, OK');
	}
}

// 'login_setting_mobile.html > 서버 정보'페이지로 이동
function goSerInfoFormMsg(button) {
	if(button == 2)	document.location.href='login_setting.html#serInfoForm';
}
