

$(document).on('click','.btn_close',function(e){ 
	  
 
	var target = $('nav'); 

	$(target).addClass('hidden');	
	$('.btn_open').removeClass('hide');	

});


$(document).on('click','.btn_open',function(e){ 
	  
 
	var target = $('nav'); 

	$(target).removeClass('hidden');	
	$('.btn_open').addClass('hide');	

});