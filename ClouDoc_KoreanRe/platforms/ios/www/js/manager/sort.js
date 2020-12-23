/* 기본 : 파일 목록 정렬창 여닫기 */
function sortDialogManager(way) {
    var dialog = $("#NetID_sortDialog");
    if ( way == "open" )
    {
        $(".contents-list").css("overflow-y", "scroll");
        dialog.show();
        $(".blank").on("click", function(){sortDialogManager("close");}).show();
        var lis = dialog.find("li").css("background-color", "#FFFFFF");
        if ( GetlocalStorage("Sort") == "LtH" )       $(lis[1]).css("background-color", "#D9D9D9");
        else if ( GetlocalStorage("Sort") == "HtL" )  $(lis[2]).css("background-color", "#D9D9D9");
        else if ( GetlocalStorage("Sort") == "new" )  $(lis[3]).css("background-color", "#D9D9D9");
        else if ( GetlocalStorage("Sort") == "old" )  $(lis[4]).css("background-color", "#D9D9D9");
        else                                            $(lis[0]).css("background-color", "#D9D9D9")
            }
    else
    {
        $(".contents-list").css("overflow-y", "scroll");
        $(".blank").off("click").hide();
        dialog.hide();
    }
}

/* 즐겨찾기 : 파일 목록 정렬창 열닫기 */
function BMSortDialogManager(way) {
    if ( nowMode == "BMEdit")   cancelEditMode();
    var dialog = $("#NetID_BMSortDialog");
    if ( way == "open" )
    {
        $(".blank").on("click", function(){BMSortDialogManager("close");}).show();
        dialog.show();
        var lis = dialog.find("li").css("background-color", "#FFFFFF");
        if ( GetlocalStorage("BMSort") == "Reg" )       $(lis[0]).css("background-color", "#D9D9D9");
        else if ( GetlocalStorage("BMSort") == "LtH" )  $(lis[1]).css("background-color", "#D9D9D9");
        else if ( GetlocalStorage("BMSort") == "HtL" )  $(lis[2]).css("background-color", "#D9D9D9");
        else                                            $(lis[3]).css("background-color", "#D9D9D9");
    }
    else
    {
        $(".blank").off("click").hide();
        dialog.hide();
    }
}

// 기본 : 폴더명 가져오기
function getListFolderName(folderInfo) {
    var tempInfo = folderInfo.split("\t");
    return tempInfo[0];
}

// 기본 : 정렬 호출
function sort(type) {
    sortDialogManager("close");
    var check_list = $(".list");
    $(".list").remove();
    
    qSort(type, check_list, 0, check_list.length - 1);
    
    for ( var i = 0; i < check_list.length; i++ ) {
        if ( $(check_list[i]).hasClass("list-folder") ) $(".contents-list").append(check_list[i]);
    }
    for ( var i = 0; i < check_list.length; i++ ) {
        if ( $(check_list[i]).hasClass("list-file") )   $(".contents-list").append(check_list[i]);
    }
    
    SetlocalStorage("Sort", type);
}

// 즐겨찾기 : 정렬 호출
function BMSort(type) {
    BMSortDialogManager("close");
    if ( type == "User" ) {
        ClearlocalStorage('BMSort');
        getBMList($('.BM-selected'));
        return;
    }
    var check_list = $(".list");
    $(".list").remove();
    
    if ( G_BMList == "" )   G_BMList = $(".contents-list").attr("id");
    if(type != "최근 문서") qSort(type, check_list, 0, check_list.length - 1);
    
    G_BMList = G_BMList.substring(1, G_BMList.length - 1).split(',');
    var result = "{";
    var filePath;
    
    if(type != "최근 문서")
    {
        for ( var i = 0; i < check_list.length; i++ ) {
            filePath = $(check_list[i]).attr('id');
            for ( var ii = 0; ii < G_BMList.length; ii++ ) {
                if ( G_BMList[ii].indexOf(filePath) > -1 ) {
                    result += result == "{"?    G_BMList[ii] : "," + G_BMList[ii];
                    break;
                }
            }
            
            $(".contents-list").append(check_list[i]);
        }
    }
    else
    {
        for ( var i = check_list.length-1; i >= 0; i-- ) {
            filePath = $(check_list[i]).attr('id');
            for ( var ii = G_BMList.length-1; ii >= 0; ii-- ) {
                if ( G_BMList[ii].indexOf(filePath) > -1 ) {
                    result += result == "{"?    G_BMList[ii] : "," + G_BMList[ii];
                    break;
                }
            }
            
            $(".contents-list").append(check_list[i]);
        }
    }
    
    G_BMList = result + "}";
    $(".BM-list").on({ touchstart : function() {touchStart(this);}, touchend : function() {touchEnd(this);}, touchmove : function() {touchEnd(this);} });
    
    if(type != "최근 문서") SetlocalStorage("BMSort", type);
}

// 기본 : 기본 정렬
function sort_default() {
    sortDialogManager("close");
    
    var check_list = $(".list");
    var folder_num = $(".list-folder").length;
    $(".list").remove();
    
    qSort("LtH", check_list, 0, folder_num - 1);
    qSort("new", check_list, folder_num, check_list.length - 1);
    
    for ( var i = 0; i < check_list.length; i++ ) {
        if ( $(check_list[i]).hasClass("list-folder") ) $(".contents-list").append(check_list[i]);
    }
    for ( var i = 0; i < check_list.length; i++ ) {
        if ( $(check_list[i]).hasClass("list-file") )   $(".contents-list").append(check_list[i]);
    }
    
    ClearlocalStorage("Sort");
}

// 퀵솔트
function qSort(type, list, left, right) {
    try{
    var pivot = list[left], l_hold = left, r_hold = right;
    while ( left < right ) {
        if ( type == "LtH" )        while ( (naturalSorter($(list[right]).data("filename"), $(pivot).data("filename")) >= 0) && (left < right) )   right--;
        else if ( type == "HtL" )   while ( (naturalSorter($(list[right]).data("filename"), $(pivot).data("filename")) <= 0) && (left < right) )   right--;
        else if ( type == "new" )   while ( ($(list[right]).data("filedate") <= $(pivot).data("filedate")) && (left < right) )    right--;
        else if ( type == "old" )   while ( ($(list[right]).data("filedate") >= $(pivot).data("filedate")) && (left < right) )   right--;
        else if ( type == "Reg" )   while ( ($(list[right]).data("filedate") >= $(pivot).data("filedate")) && (left < right) )    right--;
        else if ( type == "getList" )   while ( (naturalSorter(getListFolderName(list[right]), getListFolderName(pivot)) >= 0) && (left < right) )   right--;
        if ( left != right )   list[left] = list[right];
        
        if ( type == "LtH" )        while ( (naturalSorter($(list[left]).data("filename"), $(pivot).data("filename")) <= 0) && (left < right) )   left++;
        else if ( type == "HtL" )   while ( (naturalSorter($(list[left]).data("filename"), $(pivot).data("filename")) >= 0) && (left < right) )   left++;
        else if ( type == "new" )   while ( ($(list[left]).data("filedate") >= $(pivot).data("filedate")) && (left < right) )   left++;
        else if ( type == "old" )   while ( ($(list[left]).data("filedate") <= $(pivot).data("filedate")) && (left < right) )   left++;
        else if ( type == "Reg" )   while ( ($(list[left]).data("filedate") <= $(pivot).data("filedate")) && (left < right) )   left++;
        else if ( type == "getList" )   while ( (naturalSorter(getListFolderName(list[left]), getListFolderName(pivot)) <= 0) && (left < right) )   left++;
        if ( left != right ) {
            list[right] = list[left];
            right--;
        }
    }
    
    list[left] = pivot;
    pivot = left;
    left = l_hold;
    right = r_hold;
    
    if ( left < pivot )     qSort(type, list, left, pivot - 1);
    if ( right > pivot )    qSort(type, list, pivot + 1, right);
    }catch(e){
        
    }
}

/**
 * <h>compare parameter1 with parameter2.</h>
 *
 * @returns   If parameter1 bigger then parameter2,<br>return positive number.
 */
function naturalSorter(parameter1, parameter2) {
    var a, b, a1, b1, i = 0, n, L, rx = /(\.\d+)|(\d+(\.\d+)?)|([^\d.]+)|(\.\D+)|(\.$)/g;
    
    if (parameter1===parameter2)   return 0;
    
    a = parameter1.toString().toLowerCase().match(rx);
    b = parameter2.toString().toLowerCase().match(rx);
    L = a.length;
    
    while ( i < L ) {
        if ( !b[i] )   return 1;
        a1 = a[i],
        b1 = b[i++];
        if ( a1!== b1 ) {
            n = a1 - b1;
            if ( !isNaN(n) )   return n;
            return ( a1 > b1 )?   1 : -1;
        }
    }
    
    return b[i]?   -1 : 0;
}

function check(list) {
    var message = "";
    for ( var i = 0; i < list.length; i++ ) {
        message += message == ""?   list[i] : "\n" + list[i];
    }
    alert(message);
}
