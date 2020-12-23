var request = false;
var request2 = false;
try {
	request = new XMLHttpRequest();
    request2 = new XMLHttpRequest();
} catch(trymicrosoft) {
	try {
		request = new ActiveXObject("Msxml2.XMLHTTP");
        request2 = new ActiveXObject("Msxml2.XMLHTTP");
	} catch(othermicrosoft) {
		try {
			request = new ActiveXObject("Microsoft.XMLHTTP");
            request2 = new ActiveXObject("Microsoft.XMLHTTP");
		} catch(failed) {
			// alert("Your browser does not support AJAX!");
			request = false;
            request2 = false;
		}
	}
}

if (!request)	alert("Error initializing XMLHttpRequest!");
if (!request2)	alert("Error initializing XMLHttpRequest!");

function AjaxRequest(protocol, port, Server, strMethod, strTarget, paraData, paraCookie) {
    try {
        var result = "";
        var test = "";
        /*
         us = new utilsocket();
         us.test(function(retVal){
         alert('success retVal = ' + retVal);
         test = retVal;
         }, function(){alert('fail');}, protocol, port, Server, strMethod, strTarget, paraData, paraCookie);
         */
        
        if(port != "80" || port != "443")
            Server = Server + ":" + port;
        request.onreadystatechange = function() {
            if (4 == request.readyState) {
                result = request.responseText;
                return result;
            }
        };
        
        request.open(strMethod, "http://"+Server+strTarget, false);
        request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        
        request.send(paraData);
    } catch(e) {
        var errMsg = "Network Error";
        return errMsg;
        var error= new String(e);
        if(error.match("Failed to load"))
            navigator.notification.alert(lang_alert_check_network, null, network_alert_title, 'OK');
    }
    result = request.responseText;
    return result;
}

function AjaxRequest2(protocol, port, Server, strMethod, strTarget, paraData, paraCookie) {
    try {
        var result = "";
        var test = "";
        /*
         us = new utilsocket();
         us.test(function(retVal){
         alert('success retVal = ' + retVal);
         test = retVal;
         }, function(){alert('fail');}, protocol, port, Server, strMethod, strTarget, paraData, paraCookie);
         */
        
        if(port != "80" || port != "443")
            Server = Server + ":" + port;
        request2.onreadystatechange = function() {
            if (4 == request2.readyState) {
                result = request2.responseText;
                return result;
            }
        };
        
        request2.open(strMethod, "http://"+Server+strTarget, false);
        request2.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        
        request2.send(paraData);
    } catch(e) {
        var errMsg = "Network Error";
        return errMsg;
        var error= new String(e);
        if(error.match("Failed to load"))
            navigator.notification.alert(lang_alert_check_network, null, network_alert_title, 'OK');
    }
    result = request2.responseText;
    return result;
}


function rest(){
    alert('rest');
}

/* function ajaxFunction() {
	var xmlHttp;
	try {	// Firefox, Opera 8.0+, Safari
		xmlHttp=new XMLHttpRequest();
	} catch(e) {	// Internet Explorer
		try {
			xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
		} catch(e) {
			try {
				xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
			} catch(e) {
				alert("Your browser does not support AJAX!");
				return false;
			}
		}
	}
	
	xmlHttp.onreadystatechange=function() {
		if(xmlHttp.readyState == 4) {
			document.getElementById("response").innerHTML = xmlHttp.responseText;
			var img = document.createElement('img');
			img.onload = function(e) {
				document.getElementById("imgHolder").width=this.width;
				document.getElementById("imgHolder").height=this.height;
				document.getElementById("imgHolder").src=this.src;
			}
			img.onerror = function(e) {
				alert("Error processing Image.  Please try again.")
			}
			img.src = xmlHttp.responseText;
		}
	}

	sendVars = "tx="+document.forms["myForm"]["txtTxt"].value;
	sendVars += "&fon=ARIAL.TTF";
	sendVars += "&sz="+document.forms["myForm"]["txtSz"].value;
	sendVars += "&fg="+document.forms["myForm"]["txtFG"].value;;
	sendVars += "&bg="+document.forms["myForm"]["txtBG"].value;;

	xmlHttp.open("POST", "testAjaxSS.php", true);
	xmlHttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");	//include this for post or it won't work!!!!
	xmlHttp.send(sendVars);
} */
