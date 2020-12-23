var select_all_flag = "false";

function showBlank() {
	$('#blank').fadeIn('fast');
}

function hideBlank() {
	$('#blank').fadeOut('fast');
}

// 다중파일모드
function multiple_mode() {
	$('#alarm_form').css('display', 'none');
	$('#alarm_select_form').css({'display':'block', 'width':$(window).width() + 'px', 'height':$(window).height() + 'px'});
	$('#alarm_select_ul').css('height', $(window).height() - $('#titleTable_select').height() - $('#alarm_select_bottom_bar').height() + 'px');
}

// 다중파일모드 취소
function multiple_mode_cancel() {
	check_cancel();
	$('#alarm_form').css('display', 'block');
	$('#alarm_select_form').css('display', 'none');
}

// 알람 모두읽음
function alarm_read() {
	var rowid = '';
	var chk = document.getElementsByName("a"); // 체크박스객체를 담는다
	var len = chk.length;    //체크박스의 전체 개수
	var checkRow = '';      //체크된 체크박스의 value를 담기위한 변수
	var checkCnt = 0;        //체크된 체크박스의 개수
	var checkLast = '';      //체크된 체크박스 중 마지막 체크박스의 인덱스를 담기위한 변수
	var cnt = 0;

	for(var i = 0; i < len; i++) {
		if(chk[i].checked == true) {
			checkCnt++;        //체크된 체크박스의 개수
			checkLast = i;     //체크된 체크박스의 인덱스
		}
	}

	for(var i=0; i<len; i++) {
		if(chk[i].checked == true) {  //체크가 되어있는 값 구분
			checkRow = chk[i].value;

			if(checkCnt == 1) {                            //체크된 체크박스의 개수가 한 개 일때,
				rowid += "'"+checkRow+"'";        //'value'의 형태 (뒤에 ,(콤마)가 붙지않게)
			} else {                                            //체크된 체크박스의 개수가 여러 개 일때,
				if(i == checkLast) {                     //체크된 체크박스 중 마지막 체크박스일 때,
					rowid += "'"+checkRow+"'";  //'value'의 형태 (뒤에 ,(콤마)가 붙지않게)
				} else {
					rowid += "'"+checkRow+"',"; //'value',의 형태 (뒤에 ,(콤마)가 붙게)
				}
			}
			cnt++;
			checkRow = '';    //checkRow초기화.
			chk[i].checked = false;
		}
	}

	$('#alarm_form').css('display', 'block');
	$('#alarm_select_form').css('display', 'none');
}
 
// 알람 삭제
function alarm_delete() {
	check_cancel();
	multiple_mode_cancel();
}

// 체크박스 체크 해제
function check_cancel() {
	var rowid = '';
	var chk = document.getElementsByName("a"); // 체크박스객체를 담는다
	var len = chk.length;    //체크박스의 전체 개수
	var checkRow = '';      //체크된 체크박스의 value를 담기위한 변수
	var checkCnt = 0;        //체크된 체크박스의 개수
	var checkLast = '';      //체크된 체크박스 중 마지막 체크박스의 인덱스를 담기위한 변수
	var cnt = 0;

	for(var i=0; i<len; i++) {
		if(chk[i].checked == true) {
			checkCnt++;        //체크된 체크박스의 개수
			checkLast = i;     //체크된 체크박스의 인덱스
		}
	}

	for(var i=0; i<len; i++) {
		if(chk[i].checked == true) {  //체크가 되어있는 값 구분
			checkRow = chk[i].value;

			if(checkCnt == 1) {                            //체크된 체크박스의 개수가 한 개 일때,
				rowid += "'"+checkRow+"'";        //'value'의 형태 (뒤에 ,(콤마)가 붙지않게)
			} else {                                            //체크된 체크박스의 개수가 여러 개 일때,
				if(i == checkLast) {                     //체크된 체크박스 중 마지막 체크박스일 때,
					rowid += "'"+checkRow+"'";  //'value'의 형태 (뒤에 ,(콤마)가 붙지않게)
				} else {
					rowid += "'"+checkRow+"',"; //'value',의 형태 (뒤에 ,(콤마)가 붙게)
				}
			}
			cnt++;
			checkRow = '';    //checkRow초기화.
			chk[i].checked = false;
		}
	}
	rowid = "";
}

// 알람 목록 전체 선택
function select_all() {
	if(select_all_flag == "false") {
		var rowid = '';
		var chk = document.getElementsByName("a"); // 체크박스객체를 담는다
		var len = chk.length;    //체크박스의 전체 개수
		var checkRow = '';      //체크된 체크박스의 value를 담기위한 변수
		var checkCnt = 0;        //체크된 체크박스의 개수
		var checkLast = '';      //체크된 체크박스 중 마지막 체크박스의 인덱스를 담기위한 변수
        var cnt = 0;

        for(var i=0; i<len; i++) {
        	if(chk[i].checked == true) {
        		checkCnt++;        //체크된 체크박스의 개수
        		checkLast = i;     //체크된 체크박스의 인덱스
        	}
        	chk[i].checked = true;
        }
        select_all_flag = "true";
        rowid = "";
	} else if(select_all_flag == "true") {
		var rowid = '';
		var chk = document.getElementsByName("a"); // 체크박스객체를 담는다
		var len = chk.length;    //체크박스의 전체 개수
		var checkRow = '';      //체크된 체크박스의 value를 담기위한 변수
		var checkCnt = 0;        //체크된 체크박스의 개수
		var checkLast = '';      //체크된 체크박스 중 마지막 체크박스의 인덱스를 담기위한 변수
		var cnt = 0;

		for(var i=0; i<len; i++) {
			if(chk[i].checked == true) {
				checkCnt++;        //체크된 체크박스의 개수
				checkLast = i;     //체크된 체크박스의 인덱스
			}
			chk[i].checked = false;
		}
		select_all_flag = "false";
		rowid = "";
	}
}

// 반려
function button_return() {
	alert('button_return');
}
 
// 승인
function open_button_approval() {
	$('#blank').on('click', close_button_approval);
	showBlank();
	$('#button_approval_dialog').css('display', 'block');
}

// 승인 창 닫기
function close_button_approval() {
	$('#blank').off('click', close_doc_export_click_filename);
	hideBlank();
	$('#button_approval_dialog').css('display', 'none');
}

function open_doc_export_click_filename() {
	$('#blank').on('click', close_doc_export_click_filename);
	showBlank();
	$('#doc_export_dialog').css('display', 'block');
}

function close_doc_export_click_filename() {
	$('#blank').off('click', close_doc_export_click_filename);
	hideBlank();
	$('#doc_export_dialog').css('display', 'none');
}

// 문서반출 승인
function doc_export_approval() {
	alert('doc_export_approval');
}

// 회원가입 승인
function join_approval() {

}

/*	문서 반출 신청	*/
function openDocExport() {
	$('#doc_export_form').css('display', 'block');
	$('#doc_export_form').animate({'left' : '0'}, 300);

	$('#doc_export_form').css({'width' : $(window).width() + 'px', 'height' : $(window).height() + 'px'});
	$('#doc_export_content').css('height', $(window).height()-$('#doc_export_title').height()-$('.alarmFooter').height() + 'px');
    $('#doc_export_file_dialog').css({'top':($(window).height() - $('#doc_export_file_dialog').height())/2 + 'px', 'left':($(window).width() - $('#doc_export_file_dialog').width())/2 + 'px'});
    $('#doc_export_dialog').css({'top':($(window).height() - $('#doc_export_dialog').height())/2 + 'px', 'left':($(window).width() - $('#doc_export_dialog').width())/2 + 'px'});
}

/*	회원 가입 신청	*/
function openSignin() {
	$('#signin_form').css('display', 'block');
	$('#signin_form').animate({'left' : '0'}, 300);

	$('#signin_form').css({'width' : $(window).width() + 'px', 'height': $(window).height() + 'px'});
	$('#signin_content').css('height', $(window).height()-$('#signin_title').height()-$('#signin_footer').height() + 'px');
	$('#signin_dialog').css({'top' : ($(window).height() - $('#signin_dialog').height()) / 2 + 'px', 'left' : ($(window).width() - $('#signin_dialog').width()) / 2 + 'px'});
}

/*	용량 추가 신청	*/
function openStorage() {
	$('#storage_form').css('display', 'block');
	$('#storage_form').animate({'left' : '0'}, 300);

	$('#storage_form').css({'width': $(window).width() + 'px', 'height': $(window).height() + 'px'});
	$('#storage_content').css('height', $(window).height()-$('#storage_title').height()-$('#storage_footer').height() + 'px');
	$('#storage_dialog').css({'top' : ($(window).height() - $('#storage_dialog').height()) / 2 + 'px', 'left' : ($(window).width() - $('#storage_dialog').width()) / 2 + 'px'});
}

/*	보안 웹링크 복사 신청	*/
function openWebLink() {
	$('#web_link_form').css('display', 'block');
	$('#web_link_form').animate({'left' : '0'}, 300);

	$('#web_link_form').css({'width': $(window).width() + 'px', 'height': $(window).height() + 'px'});
	$('#web_link_content').css('height', $(window).height()-$('#web_link_title').height()-$('#web_link_footer').height() + 'px');
	$('#web_link_file_dialog').css({'top':($(window).height() - $('#web_link_file_dialog').height())/2 + 'px', 'left':($(window).width() - $('#web_link_file_dialog').width())/2 + 'px'});
	$('#web_link_dialog').css({'top' : ($(window).height() - $('#web_link_dialog').height()) / 2 + 'px', 'left' : ($(window).width() - $('#web_link_dialog').width()) / 2 + 'px'});
}

/*	디바이스 등록 신청	*/
function openDevice() {
	$('#device_form').css('display', 'block');
	$('#device_form').animate({'left' : '0'}, 300);

	$('#device_form').css({'width': $(window).width() + 'px', 'height': $(window).height() + 'px'});
	$('#device_content').css('height', $(window).height()-$('#device_title').height()-$('#device_footer').height() + 'px');
	$('#device_dialog').css({'top' : ($(window).height() - $('#device_dialog').height()) / 2 + 'px', 'left' : ($(window).width() - $('#device_dialog').width()) / 2 + 'px'});
}

/*	문서인계 신청	*/
function openTransfer() {
	$('#transfer_form').css('display', 'block');
	$('#transfer_form').animate({'left' : '0'}, 300);

	$('#transfer_form').css({'width': $(window).width() + 'px', 'height': $(window).height() + 'px'});
	$('#transfer_content').css('height', $(window).height()-$('#transfer_title').height()-$('#transfer_footer').height() + 'px');
	$('#transfer_dialog').css({'top' : ($(window).height() - $('#transfer_dialog').height()) / 2 + 'px', 'left' : ($(window).width() - $('#transfer_dialog').width()) / 2 + 'px'});
}

/*	클라이언트 삭제 신청	*/
function openClientDelete() {
	$('#client_delete_form').css('display', 'block');
	$('#client_delete_form').animate({'left' : '0'}, 300);

	$('#client_delete_form').css({'width': $(window).width() + 'px', 'height': $(window).height() + 'px'});
	$('#client_delete_content').css('height', $(window).height()-$('#client_delete_title').height()-$('#client_delete_footer').height() + 'px');
	$('#client_delete_dialog').css({'top' : ($(window).height() - $('#client_delete_dialog').height()) / 2 + 'px', 'left' : ($(window).width() - $('#client_delete_dialog').width()) / 2 + 'px'});
}

/*	QnA	*/
function openQna() {
	$('#qna_form').css('display', 'block');
	$('#qna_form').animate({'left' : '0'}, 300);

	$('#qna_form').css({'width': $(window).width() + 'px', 'height': $(window).height() + 'px'});
	$('#qna_content').css('height', $(window).height()-$('#qna_title').height()-$('#qna_footer').height() + 'px');
	$('#qna_dialog').css({'top' : ($(window).height() - $('#qna_dialog').height()) / 2 + 'px', 'left' : ($(window).width() - $('#qna_dialog').width()) / 2 + 'px'});
}

/*	커뮤니티 생성 신청	*/
function openCommynityCreate() {
	$('#community_create_form').css('display', 'block');
	$('#community_create_form').animate({'left' : '0'}, 300);
	
	$('#community_create_form').css({'width': $(window).width() + 'px', 'height': $(window).height() + 'px'});
	$('#community_create_content').css('height', $(window).height()-$('#community_create_title').height()-$('#community_create_footer').height() + 'px');
	$('#community_create_dialog').css({'top' : ($(window).height() - $('#community_create_dialog').height()) / 2 + 'px', 'left' : ($(window).width() - $('#community_create_dialog').width()) / 2 + 'px'});
}

/*	커뮤니티 가입 신청	*/
function openCommunityJoin() {
	$('#community_join_form').css('display', 'block');
	$('#community_join_form').animate({'left' : '0'}, 300);

	$('#community_join_form').css({'width': $(window).width() + 'px', 'height': $(window).height() + 'px'});
	$('#community_join_content').css('height', $(window).height()-$('#community_join_title').height()-$('#community_join_footer').height() + 'px');
	$('#community_join_dialog').css({'top' : ($(window).height() - $('#community_join_dialog').height()) / 2 + 'px', 'left' : ($(window).width() - $('#community_join_dialog').width()) / 2 + 'px'});
}

/*	커뮤니티 새글 알림	*/
function openCommunityAlert() {
	$('#community_alert_form').css('display', 'block');
	$('#community_alert_form').animate({'left' : '0'}, 300);

	$('#community_alert_form').css({'width': $(window).width() + 'px', 'height': $(window).height() + 'px'});
	$('#community_alert_content').css('height', $(window).height()-$('#community_alert_title').height()-$('#community_alert_footer').height() + 'px');
	$('#community_alert_file_dialog').css({'top':($(window).height() - $('#community_alert_file_dialog').height())/2 + 'px', 'left':($(window).width() - $('#community_alert_file_dialog').width())/2 + 'px'});
}

/*	공지사항	*/
function openNotice() {
	$('#notice_form').css('display', 'block');
	$('#notice_form').animate({'left' : '0'}, 300);

	$('#notice_form').css({'width': $(window).width() + 'px', 'height': $(window).height() + 'px'});
	$('#notice_content').css('height', $(window).height()-$('#notice_title').height()-$('#notice_footer').height() + 'px');
	var notice_attachBox_list_count = $('#notice_attachBox li').length;
	var notice_attachBox_list_appenHeight = (notice_attachBox_list_count-1) * $('#notice_attachBox li').height();
	$('#notice_attachBox').css('height', $('#notice_attachBox').height() + notice_attachBox_list_appenHeight);
	$('#notice_file_dialog').css({'top':($(window).height() - $('#notice_file_dialog').height())/2 + 'px', 'left':($(window).width() - $('#notice_file_dialog').width())/2 + 'px'});
}

/*	서버 경고 알림	*/
function openServerAlert() {
	$('#server_alert_form').css('display', 'block');
	$('#server_alert_form').animate({'left' : '0'}, 300);

	$('#server_alert_form').css({'width': $(window).width() + 'px', 'height': $(window).height() + 'px'});
	$('#server_alert_content').css('height', $(window).height()-$('#server_alert_title').height()-$('#server_alert_footer').height() + 'px');
}

/*	알림 메시지 창 닫기	*/
function closeForm(obj) {
	$(obj).closest('div').animate({'left' : $(obj).closest('div').width()}, 300, function(){});
}
