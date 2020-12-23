// 토스트창 보여주기
function showToast(message) {
	if($('#toast').css('display') != 'none') {
		$('#toast').css('display', 'none');
	}

	$('#toastContent').text(message);
	$('#toast').fadeIn(500);
	setTimeout(hideToast, 1000);
}

// 토스트창 감추기
function hideToast() {
	$('#toast').fadeOut(1500);
}

// 로그 확인
function log(context) {
	$('#log').html(context);
}