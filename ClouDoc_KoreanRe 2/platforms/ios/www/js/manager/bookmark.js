// 기존 추가 여부 표시
function checkBMExist() {
    var BMList = new Array();
    try{
        Entertainment = new Entertainment();
        Entertainment.getBMList(function(result) {
                                // Get bookmark file list
                                result = $.parseJSON(result);
                                $.each(result, function(folderName, files) {
                                       if(folderName == "최근 문서") return true;
                                       $.each(files, function(filePath, fileInfo) {
                                              BMList.push(filePath);
                                              });
                                       });
                                
                                // Check files in BMList
                                var fList = $(".list img:nth-child(4)");
                                for ( var i = 0; i < fList.length; i++ ) {
                                if ( $.inArray(paraDiskType + $(fList[i]).attr("id"), BMList) > -1 )    $(fList[i]).removeClass("list-BM-unchecked").addClass("list-BM-checked");
                                }
                                }, function(){}, GetlocalStorage("id"));
    }catch(e){
        Entertainment.getBMList(function(result) {
                                // Get bookmark file list
                                result = $.parseJSON(result);
                                $.each(result, function(folderName, files) {
                                       if(folderName == "최근 문서") return true;
                                       $.each(files, function(filePath, fileInfo) {
                                              BMList.push(filePath);
                                              });
                                       });
                                
                                // Check files in BMList
                                var fList = $(".list img:nth-child(4)");
                                
                                for ( var i = 0; i < fList.length; i++ ) {
                                if ( $.inArray(paraDiskType + $(fList[i]).attr("id"), BMList) > -1 )    $(fList[i]).removeClass("list-BM-unchecked").addClass("list-BM-checked");
                                }
                                
                                }, function(){}, GetlocalStorage("id"));
    }
}

// 즐겨찾기 추가 창
function BMAppendDialogManager(way, type, para1, para2, permission) {
    var dialog = $(".dialog-BM-append");
    dialog.find("input[type=hidden]:nth-child(1)").val(type);
    dialog.find("input[type=hidden]:nth-child(2)").val(para1);
    dialog.find("input[type=hidden]:nth-child(3)").val(para2);
    dialog.find("input[type=hidden]:nth-child(4)").val(permission);
    
    if ( way == "open" )
    {
        $(".contents-list").css("overflow-y", "hidden");
        $(".blank").on("click", function(){BMAppendDialogManager("close", '', '', '');}).show();
        dialog.show();
        appendBMFolderList("append");
    }
    else
    {
        $(".contents-list").css("overflow-y", "scroll");
        $(".blank").off("click").hide();
        dialog.hide();
    }
}

// 즐겨찾기 제거 창
function BMRemoveDialogManager(way, path) {
    var dialog = $("#NetID_BMRemoveDialog");
    if ( way == "open" )
    {
        $(".blank").on("click", function(){BMRemoveDialogManager("close", '');}).show();
        dialog.find("input:first-child").attr("id", path);
        dialog.find("div:nth-child(2) label").text(path.replace("personal", "개인문서함").replace("orgcowork", "공유문서함").replace(/\//gi, " > "));
        dialog.show();
    }
    else
    {
        $(".blank").off("click").hide();
        dialog.find("input:first-child").attr("id", "");
        dialog.find("div:nth-child(2) label").text();
        dialog.hide();
    }
}

// 즐겨찾기 추가
function appendBM(folderName) {
    var dialog = $(".dialog-BM-append");
    var type = dialog.find("input[type=hidden]:nth-child(1)").val();
    var permission = dialog.find("input[type=hidden]:nth-child(4)").val();
                                                                                                                           
    if ( type == "folder" )
    {
        var treeID = dialog.find("input[type=hidden]:nth-child(2)").val();
        var path = paraDiskType + dialog.find("input[type=hidden]:nth-child(3)").val();
        
        var fileInfo = type + "\t" + treeID + "\t" + tmpOwner + "\t" + tmpFileServer + "\t" + tmpPartition + "\t" + tmpStartPath + "\t" + tmpUserPath + "\t" + paraDiskType + "\t" + tmpShareUser + "\t" + tmpShareOwner + "\t" + permission;
    }
    else
    {
        var fileName = dialog.find("input[type=hidden]:nth-child(2)").val();
        var fileSize = dialog.find("input[type=hidden]:nth-child(3)").val();
        
        var path = tmpUserPath == "/"?  paraDiskType + tmpUserPath + fileName : paraDiskType + tmpUserPath + "/" + fileName;
        var fileInfo = type + "\t" + paraDiskType + "\t" + tmpPartition + "\t" + option + "\t" + tmpOwner + "\t" + tmpShareUser + "\t" + tmpShareOwner + "\t" + tmpStartPath + "\t" + tmpOrgCode + "\t" + tmpFileServer + "\t" + fileSize + "\t" + permission;
    }
    
    try{
        Entertainment = new Entertainment();
        Entertainment.appendBM(function(result) {
                           BMAppendDialogManager("close", '', '', '');
                           if ( result == "success" )
                           {
                           checkBMExist();
                           }
                           else if ( result == "exist" )
                           {
                           navigator.notification.alert("이미 존재하는 즐겨찾기 입니다.", function(){}, "", "확인");
                           }
                           }, function(){}, User, folderName, path, fileInfo);
    }catch(e){
        Entertainment.appendBM(function(result) {
                               BMAppendDialogManager("close", '', '', '');
                               if ( result == "success" )
                               {
                               checkBMExist();
                               }
                               else if ( result == "exist" )
                               {
                               navigator.notification.alert("이미 존재하는 즐겨찾기 입니다.", function(){}, "", "확인");
                               }
                               }, function(){}, User, folderName, path, fileInfo);
    }
}

// 즐겨찾기 제거
function removeBM(path) {
    BMRemoveDialogManager("close", '');
    var folderItem = $(".BM-selected");
    var folderName = folderItem.find("label").text();
    try{
        Entertainment = new Entertainment();
        Entertainment.removeBM(function(){getBMList(folderItem);}, function(){}, User, folderName, path);
    }catch(e){
        Entertainment.removeBM(function(){getBMList(folderItem);}, function(){}, User, folderName, path);
    }
}

// 즐겨찾기 파일리스트
function getBMList(target) {
    nowPage = "bookmark";
    // 상단 타이틀 변경
    $(".contents-title").hide();
                                                                                                                           
    if($(target).find("label").text() == "최근 문서") $(".recent-title").show();
    else $(".bookmark-title").show();
                                                                                                                           
    $("#NetID_currentBMFolder").text(" > " + $(target).find("label").text());
    $(".contents-title > div:nth-child(3)").show();
    
    // 좌측 : 트리구조 선택 해제
    $(".tree-drive-selected").removeClass("tree-drive-selected");
    $(".tree-selected").removeClass("tree-selected");
                                                                                                                           
    // 즐겨찾기 폴더 선택 표시
    $(".BM-selected").removeClass("BM-selected");
    $(target).addClass("BM-selected");
    $(".list").remove();
    $(".contents-list").scrollTop();
    try{
        Entertainment = new Entertainment();
        Entertainment.getBMList(function(result) {
                                if ( result == "" ) return;
                                var BMInfoJson = $.parseJSON(result);
                                $.each(BMInfoJson, function(folderName, files) {
                                       if ( folderName != $(target).find("label").text() )    return true;
                                       $(".contents-list").attr("id", JSON.stringify(files));
                                       var count = 0;
                                       $.each(files, function(filePath, fileInfo) {
                                              count++;
                                              var infos = fileInfo.split("\t");
                                              var upperPath = filePath.substring(0, filePath.lastIndexOf('/')).replace("personal", "개인문서함").replace("orgcowork", "공유문서함").replace(/\//gi, " > ");
                                              var appendTime = infos[0].substring(0, 4) + '-' + infos[0].substring(4, 6) + '-' + infos[0].substring(6, 8);
                                              var info = infos[0].substring(8, 10) + ':' + infos[0].substring(10, 12);
                                              var fileName = filePath.substring(filePath.lastIndexOf('/') + 1);
                                              var className = "list BM-list";
                                              if ( GetlocalStorage("BMShowPath") == "show" )  className += " BM-showPath";
                                              if ( GetlocalStorage("fileShowInfo") == "show" )    className += " showInfo";
                                              if ( folderName == "최근 문서" ) nowPage = "recent";
                                                                                                                                                                                  if( folderName == "최근 문서" && Object.keys(files).length-count >= 50 )
                                                                                                                                                                                  {
                                                                                                                                                                                  try{
                                                                                                                                                                                  Entertainment = new Entertainment();
                                                                                                                                                                                  Entertainment.removeBM(function(){}, function(){}, User, "최근 문서", filePath);
                                                                                                                                                                                  }catch(e){
                                                                                                                                                                                  Entertainment.removeBM(function(){}, function(){}, User, "최근 문서", filePath);
                                                                                                                                                                                  }
                                                                                                                                                                                  return true;
                                                                                                                                                                                  }
                                                                                                                                                                                  
                                                                                                                                                                                  
                                                                                                                                                                                  if ( infos[2] == "folder" )
                                                                                                                                                                                  {
                                                                                                                                                                                  className += " list-folder";
                                                                                                                                                                                  $(".contents-list").append("<div data-filename='" + fileName + "' data-filedate='" + infos[0] + "' id='" + filePath + "' name='" + fileInfo + "' class='" + className + "'><img src='images/file_icon/flo.png' onclick=\"bookmarkDownFolder('" + fileInfo + "')\"><label class='openedMenu' onclick=\"bookmarkDownFolder('" + fileInfo + "')\"><p>" + fileName + "</p><p>" + upperPath + "</p></label><label onclick=\"bookmarkDownFolder('" + fileInfo + "')\"><p>" + appendTime + "</p><p>" + info + "</p></label><img id='" + filePath + "' class='" + filePath.substring(0, filePath.indexOf('/')) + "' onclick=\"BMRemoveDialogManager('open', this.id)\"><input type='radio' name='editBM'></div>");
                                                                                                                                                                                  }
                                                                                                                                                                                  else
                                                                                                                                                                                  {
                                                                                                                                                                                  className += " list-file";
                                                                                                                                                                                  info += "&nbsp;&nbsp;" + size_format(infos[12]);
                                                                                                                                                                                  var icon = "images/file_icon/" + get_fileicon(fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase()) + ".png";
                                                                                                                                                                                  
                                                                                                                                                                                  /** Check selected **/
                                                                                                                                                                                  var path = infos[1];
                                                                                                                                                                                  var selectClassName = ( "select" == nowMode && mSelectedFiles.hasOwnProperty(path) )? "list-checked" : "list-unchecked";
                                                                                                                                                                                  
                                                                                                                                                                                  if(folderName != "최근 문서")
                                                                                                                                                                                  {
                                                                                                                                                                                  $(".contents-list").append("<div data-filename='" + fileName + "' data-filedate='" + infos[0] + "' id='" + filePath + "' name='" + fileInfo + "' class='" + className + "'><img src='" + icon + "' onclick=\"bookmarkOpenFile('" + fileInfo + "')\"><label class='openedMenu' onclick=\"bookmarkOpenFile('" + fileInfo + "')\"><p>" + fileName + "</p><p>" + upperPath + "</p></label><label onclick=\"bookmarkOpenFile('" + fileInfo + "')\"><p>" + appendTime + "</p><p>" + info + "</p></label><img id='" + filePath + "' class='" + filePath.substring(0, filePath.indexOf('/')) + "' onclick=\"BMRemoveDialogManager('open', this.id)\"><input type='radio' name='editBM'><img class='" + selectClassName + "' onclick=\"addSelectedFile(this, '" + fileInfo + "')\"></div>");
                                                                                                                                                                                  }
                                                                                                                                                                                  else
                                                                                                                                                                                  {
                                                                                                                                                                                  $(".contents-list").append("<div data-filename='" + fileName + "' data-filedate='" + infos[0] + "' id='" + filePath + "' name='" + fileInfo + "' class='" + className + " recent_list'><img src='" + icon + "' onclick=\"bookmarkOpenFile('" + fileInfo + "')\"><label class='openedMenu' onclick=\"bookmarkOpenFile('" + fileInfo + "')\"><p>" + fileName + "</p><p>" + upperPath + "</p></label><label onclick=\"bookmarkOpenFile('" + fileInfo + "')\"><p>" + appendTime + "</p><p>" + info + "</p></label><img class='" + selectClassName + "' onclick=\"addSelectedFile(this, '" + fileInfo + "')\"></div>");
                                                                                                                                                                                  }
                                                                                                                                                                                  }
                                              });
                                              $(".BM-list").on({ touchstart : function() {touchStart(this);}, touchend : function() {touchEnd(this);}, touchmove : function() {touchEnd(this);} });
                                              if ( folderName == "최근 문서" ) BMSort("최근 문서");
                                              else if ( GetlocalStorage("BMSort") != null )  BMSort(GetlocalStorage("BMSort"));
                                              if ( $(".contents-search input").val() != "" )  searchFile();
                                       });
                                }, function(){}, GetlocalStorage("id"));
    }catch(e){
        Entertainment.getBMList(function(result) {
                                if ( result == "" ) return;
                                var BMInfoJson = $.parseJSON(result);
                                $.each(BMInfoJson, function(folderName, files) {
                                       if ( folderName != $(target).find("label").text() )    return true;
                                       var filesStr = JSON.stringify(files);
                                       G_BMList = filesStr;
                                       $(".contents-list").attr("id", filesStr);
                                       var count = 0;
                                       $.each(files, function(filePath, fileInfo) {
                                              count++;
                                              var infos = fileInfo.split("\t");
                                              var upperPath = filePath.substring(0, filePath.lastIndexOf('/')).replace("personal", "개인문서함").replace("orgcowork", "공유문서함").replace(/\//gi, " > ");
                                              var appendTime = infos[0].substring(0, 4) + '-' + infos[0].substring(4, 6) + '-' + infos[0].substring(6, 8);
                                              var info = infos[0].substring(8, 10) + ':' + infos[0].substring(10, 12);
                                              var fileName = filePath.substring(filePath.lastIndexOf('/') + 1);
                                              var className = "list BM-list";
                                              if ( GetlocalStorage("BMShowPath") == "show" )  className += " BM-showPath";
                                              if ( GetlocalStorage("fileShowInfo") == "show" )    className += " showInfo";
                                              if ( folderName == "최근 문서" ) nowPage = "recent";
                                                                                                                                                                                  
                                                                                                                                                                                  if( folderName == "최근 문서" && Object.keys(files).length-count >= 50 )
                                                                                                                                                                                  {
                                                                                                                                                                                  try{
                                                                                                                                                                                  Entertainment = new Entertainment();
                                                                                                                                                                                  Entertainment.removeBM(function(){}, function(){}, User, "최근 문서", filePath);
                                                                                                                                                                                  }catch(e){
                                                                                                                                                                                  Entertainment.removeBM(function(){}, function(){}, User, "최근 문서", filePath);
                                                                                                                                                                                  }
                                                                                                                                                                                  return true;
                                                                                                                                                                                  }
                                                                                                                                                                                  
                                                                                                                                                                                  if ( infos[2] == "folder" )
                                                                                                                                                                                  {
                                                                                                                                                                                  className += " list-folder";
                                                                                                                                                                                  $(".contents-list").append("<div data-filename='" + fileName + "' data-filedate='" + infos[0] + "' id='" + filePath + "' name='" + fileInfo + "' class='" + className + "'><img src='images/file_icon/flo.png' onclick=\"bookmarkDownFolder('" + fileInfo + "')\"><label class='openedMenu' onclick=\"bookmarkDownFolder('" + fileInfo + "')\"><p>" + fileName + "</p><p>" + upperPath + "</p></label><label onclick=\"bookmarkDownFolder('" + fileInfo + "')\"><p>" + appendTime + "</p><p>" + info + "</p></label><img id='" + filePath + "' class='" + filePath.substring(0, filePath.indexOf('/')) + "' onclick=\"BMRemoveDialogManager('open', this.id)\"><input type='radio' name='editBM'></div>");
                                                                                                                                                                                  }
                                                                                                                                                                                  else
                                                                                                                                                                                  {
                                                                                                                                                                                  className += " list-file";
                                                                                                                                                                                  info += "&nbsp;&nbsp;" + size_format(infos[12]);
                                                                                                                                                                                  var icon = "images/file_icon/" + get_fileicon(fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase()) + ".png";
                                                                                                                                                                                  
                                                                                                                                                                                  /** Check selected **/
                                                                                                                                                                                  var path = infos[1];
                                                                                                                                                                                  var selectClassName = ( "select" == nowMode && mSelectedFiles.hasOwnProperty(path) )? "list-checked" : "list-unchecked";
                                                                                                                                                                                  
                                                                                                                                                                                  if(folderName != "최근 문서")
                                                                                                                                                                                  {
                                                                                                                                                                                  $(".contents-list").append("<div data-filename='" + fileName + "' data-filedate='" + infos[0] + "' id='" + filePath + "' name='" + fileInfo + "' class='" + className + "'><img src='" + icon + "' onclick=\"bookmarkOpenFile('" + fileInfo + "')\"><label class='openedMenu' onclick=\"bookmarkOpenFile('" + fileInfo + "')\"><p>" + fileName + "</p><p>" + upperPath + "</p></label><label onclick=\"bookmarkOpenFile('" + fileInfo + "')\"><p>" + appendTime + "</p><p>" + info + "</p></label><img id='" + filePath + "' class='" + filePath.substring(0, filePath.indexOf('/')) + "' onclick=\"BMRemoveDialogManager('open', this.id)\"><input type='radio' name='editBM'><img class='" + selectClassName + "' onclick=\"addSelectedFile(this, '" + fileInfo + "')\"></div>");
                                                                                                                                                                                  }
                                                                                                                                                                                  else
                                                                                                                                                                                  {
                                                                                                                                                                                  $(".contents-list").append("<div data-filename='" + fileName + "' data-filedate='" + infos[0] + "' id='" + filePath + "' name='" + fileInfo + "' class='" + className + " recent_list'><img src='" + icon + "' onclick=\"bookmarkOpenFile('" + fileInfo + "')\"><label class='openedMenu' onclick=\"bookmarkOpenFile('" + fileInfo + "')\"><p>" + fileName + "</p><p>" + upperPath + "</p></label><label onclick=\"bookmarkOpenFile('" + fileInfo + "')\"><p>" + appendTime + "</p><p>" + info + "</p></label><img class='" + selectClassName + "' onclick=\"addSelectedFile(this, '" + fileInfo + "')\"></div>");
                                                                                                                                                                                  }
                                                                                                                                                                                  }
                                              });
                                              $(".BM-list").on({ touchstart : function() {touchStart(this);}, touchend : function() {touchEnd(this);}, touchmove : function() {touchEnd(this);} });
                                              if ( folderName == "최근 문서" ) BMSort("최근 문서");
                                              else if ( GetlocalStorage("BMSort") != null )  BMSort(GetlocalStorage("BMSort"));
                                              if ( $(".contents-search input").val() != "" )  searchFile();
                                              if ( nowMode == "select" ) selectMode(true);
                                       });
                                }, function(){}, GetlocalStorage("id"));
    }
                                
}

// 즐겨찾기 폴더 열기
function bookmarkDownFolder(folderInfo) {
    if ( nowMode == "BMEdit" )  return;
    var infos = folderInfo.split("\t");
                                if(infos[3] == null) infos[3] = "";
                                if(infos[4] == null) infos[4] = "";
                                if(infos[5] == null) infos[5] = "";
                                if(infos[6] == null) infos[6] = "";
                                if(infos[7] == null) infos[7] = "";
                                if(infos[8] == null) infos[8] = "";
                                if(infos[9] == null) infos[9] = "";
                                if(infos[10] == null) infos[10] = "";
                                if(infos[11] == null) infos[11] = "";
    downFolder(infos[3], infos[1].substring(infos[1].lastIndexOf('/') + 1), infos[4], infos[5], infos[6], infos[7], infos[8], infos[9], infos[10], infos[11]);
}


// 즐겨찾기 파일 열기
function bookmarkOpenFile(fileInfo) {
    if ( nowMode == "BMEdit" )  return;
                                
    if ( "select" == nowMode ) {
        addSelectedFile(openTargetList, fileInfo);
        return;
    }
                                
    $(openTargetList).css('background-color', '#E5F3FB');
    var infos = fileInfo.split("\t");
    paraDiskType = infos[3];
    tmpPartition = infos[4];
    option = infos[5];
    tmpOwner = infos[6];
    tmpShareUser = infos[7];
    tmpShareOwner = infos[8];
    tmpStartPath = infos[9];
    tmpOrgCode = infos[10];
    srcName = infos[1];
    G_fileName = srcName.substring(srcName.lastIndexOf("/") + 1);
    tmpFileServer = infos[11];
    useSSL = GetlocalStorage("SSL");
    FileServerPort = useSSL == "yes"?   GetlocalStorage("FileSSlPort") : GetlocalStorage("FileHttpPort");
    siteid = GetlocalStorage("SiteID");
    tmpfilesize = infos[12];
    attribute = "0";
    overwrite = "";
    offset = "";
                                
                                if(infos[13])
                                {
                                if(infos[13].indexOf('r') == -1)
                                {
                                navigator.notification.confirm("파일 열기 권한이 없습니다.", function(){}, "", ["확인"]);
                                return;
                                }
                                else
                                {
                                tmpLocalpath = tmpLocalRootPath + "/ECM";
                                
                                var fileInfo = "file" + "\t" + paraDiskType + "\t" + tmpPartition + "\t" + option + "\t" + tmpOwner + "\t" + tmpShareUser + "\t" + tmpShareOwner + "\t" + tmpStartPath + "\t" + tmpOrgCode + "\t" + tmpFileServer + "\t" + tmpfilesize;
                                //                                var path = tmpUserPath == "/"?  paraDiskType + tmpUserPath + G_fileName : paraDiskType + tmpUserPath + "/" + G_fileName;
                                var path = paraDiskType + srcName;
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
                                
                                try{
                                useProxy = GetlocalStorage("useProxy");
                                updownmanager = new UpDownManager();
                                updownmanager.download(SuccessFileOpen, failMsg, tmpDomainID, paraDiskType, User, tmpPartition, tmpWebServer, Agent, option, tmpOwner, tmpShareUser, tmpShareOwner, tmpStartPath, tmpOrgCode, srcName, tmpFileServer, useSSL, FileServerPort, "fileopen", siteid, attribute, tmpfilesize, tmpLocalpath, overwrite, offset, useProxy, fileInfo);
                                } catch(e){
                                useProxy = GetlocalStorage("useProxy");
                                updownmanager.download(SuccessFileOpen, failMsg, tmpDomainID, paraDiskType, User, tmpPartition, tmpWebServer, Agent, option, tmpOwner, tmpShareUser, tmpShareOwner, tmpStartPath, tmpOrgCode, srcName, tmpFileServer, useSSL, FileServerPort, "fileopen", siteid, attribute, tmpfilesize, tmpLocalpath, overwrite, offset, useProxy, fileInfo);
                                }
                                }
                                }
                                else
                                {
                                navigator.notification.confirm("파일 열기 권한이 없습니다.", function(){}, "", ["확인"]);
                                return;
                                }
}

/* 편집모드 */
var G_tempBMList = "";
function editMode() {
    if ( nowMode == "BMEdit" ) {
        cancelEditMode(true);
        return;
    }
    nowMode = "BMEdit";
    try{
        G_tempBMList = G_BMList == ""?  $(".contents-list").attr("id") : G_BMList;
        var list = $(".BM-list");
        var BMBottom = $(".BM-bottom");
        
        // File list radio button
        list.find("img:nth-child(4)").hide();
        list.find("input:checked").attr("checked", false);
        list.find("input").show();
        
        // Bottom
        if ( $("#NetID_BMBlank").length < 1 )   $(".contents-list").append("<div id='NetID_BMBlank' style='height: 50px;'></div>");
        BMBottom.show();
        BMBottom.animate({"height" : "50px"}, 300);
                                
        $(".BM-bottom input:nth-child(3)").off("click").on("click", function() {
            navigator.notification.confirm("사용자 정렬로 저장됩니다.\n계속 진행하시겠습니까?", function(button) {
                                                                                                                  if ( button == 1)
                                                                                                                  {
                                                                                                                  try{
                                                                                                                  Entertainment = new Entertainment();
                                                                                                                  Entertainment.changeBM(function(){
                                                                                                                                         G_tempBMList = G_BMList;
                                                                                                                                         ClearlocalStorage("BMSort")
                                                                                                                                         cancelEditMode();
                                                                                                                                         }, function(){}, GetlocalStorage("id"), currentFolderName, G_BMList);
                                                                                                                  }catch(e){
                                                                                                                  Entertainment.changeBM(function(){
                                                                                                                                         G_tempBMList = G_BMList;
                                                                                                                                         ClearlocalStorage("BMSort")
                                                                                                                                         cancelEditMode();
                                                                                                                                         }, function(){}, GetlocalStorage("id"), $(".BM-selected label").text(), G_BMList);
                                                                                                                  }
                                                                                                                  }
                                                                                                                  else
                                                                                                                  {
                                                                                                                  cancelEditMode(true);
                                                                                                                  }
                                                                                                                  }, "", ["확인", "취소"]);
                                                                                   });
    }catch(e){
        alert('err = ' + e);
    }
}

/* 편집모드 취소 */
function cancelEditMode(refresh) {
    if ( nowMode != "BMEdit" ) return;
    nowMode = "none";
    var list = $(".BM-list");
    var BMBottom = $(".BM-bottom");
    G_BMList = G_tempBMList;
                                
    // File list radio button
    list.find("img:nth-child(4)").show();
    list.find("input").hide();
                                
    // Bottom
    $("#NetID_BMBlank").remove();
    BMBottom.animate({"height" : "0px"}, function(){$(this).hide();});
                                
    if ( nowPage == "bookmark" && refresh )    getBMList($(".BM-selected"));
}

// 편집모드 - 파일 항목 위아래 이동
var G_BMList = "";
function BMEdit_changeOrder(direction) {
    try{
        // Move file position on list
        var target = $(".BM-list input:checked").parent();
        if ( direction == "up" )    target.insertBefore(target.prev());
        if ( direction == "down" ) {
            var nextNode = target.next();
            if ( nextNode.attr("id") != "NetID_BMBlank" )   target.insertAfter(nextNode);
            else                                            return;
        }
        
        target = target.attr("id");
        if ( G_BMList == "" )   G_BMList = $(".contents-list").attr("id");
                                
        // Change position on JSONObject
        G_BMList = G_BMList.substring(1, G_BMList.length - 1).split(',');
        var result = "{";
        var standard;
        for ( var index = 0; index < G_BMList.length; index++ ) {
            standard = direction == "up"?   index + 1 : index;
            if ( index < G_BMList.length - 1 &&  G_BMList[standard].substring(G_BMList[standard].indexOf("\"") + 1, G_BMList[standard].indexOf(":") - 1) == target ) {
                result += result == "{"?    G_BMList[index + 1] : "," + G_BMList[index + 1];
            }
            if ( result.indexOf(G_BMList[index]) < 0 )  result += result == "{"?    G_BMList[index] : "," + G_BMList[index];
        }
        G_BMList = result + "}";
    }catch(e){
        alert('err = ' + e);
    }
}

var previousMenu = "";
var G_tempBMFolList = "";
                                
// 즐겨찾기 폴더목록 가져오기
function appendBMFolderList(where) {
    try{
        Entertainment = new Entertainment();
        Entertainment.getBMList(function(result) {
                                if ( result == "" ) {
//                                Entertainment.appendBMFolder(function(result) { alert("result2 " + result); if ( result == "success" ){ appendBMFolderList("menu"); } return; }, function(){}, GetlocalStorage("UserID"), "즐겨찾기");
                                appendBMFolderList("menu");
                                } else {
                                var BMInfoJson = $.parseJSON(result);
                                var dialog;
                                
                                if ( where == "menu" )
                                {
                                dialog = $(".BM-title").next();
                                dialog.find("> div").remove();
                                }
                                else if ( where == "append" )
                                {
                                dialog = $(".dialog-BM-append");
                                dialog.find("li").remove();
                                }
                                else if ( where == "edit" )
                                {
                                dialog = $(".dialog-BM-edit");
                                dialog.find("li").remove();
                                
                                dialog.data("BMList", result.replace(/\n/gi, ''));
                                G_BMFolList = G_tempBMFolList = result.replace(/\n/gi, '');
                                }
                                // Append list
                                //                                $.each(BMInfoJson, function(folderName, files) {
                                var resultSplit = result.split("\" : {");
                                for ( var index = 0; index < resultSplit.length - 1; index++ ) {
                                var folderName = resultSplit[index].substring(resultSplit[index].lastIndexOf("\"") + 1);
                                if(folderName != "최근 문서")
                                {
                                if ( where == "menu" )          dialog.append("<div class='BM-folder' onclick='getBMList(this)'><img src='images/icon/nav-folder-03.png'><label>" + folderName + "</label><span></span></div>");
                                else if ( where == "append" )   dialog.find("ul").append("<li ontouchstart onclick=\"appendBM('" + folderName + "')\"><label class='imgLabel'></label><label>" + folderName + "</label></li>");
                                else if ( where == "edit" )     dialog.find("ul").append("<li><img onclick=\"removeBMFolder(this)\"/><img/><label>" + folderName + "</label><img onclick=\"BMEdit_changeFolOrder(this, 'down')\"><img onclick=\"BMEdit_changeFolOrder(this, 'up')\"><input type='button' value='수정' onclick=\"BMFolChangeDialogManager('open', this)\"><span></span></li>");
                                if ( where == "menu" && previousMenu == folderName )    dialog.find("> div:last-child").addClass("BM-selected");
                                //                                       });
                                }
                                }
                                }
                                
                                
                                }, function(){}, GetlocalStorage("id"));
    }catch(e){
        Entertainment.getBMList(function(result) {
                                if ( result == "" ){
//                                Entertainment.appendBMFolder(function(result) { if ( result == "success" )  appendBMFolderList("menu"); return; }, function(){}, GetlocalStorage("UserID"), "즐겨찾기");
                                appendBMFolderList("menu");
                                } else {
                                var BMInfoJson = $.parseJSON(result);
                                var dialog;
                                
                                if ( where == "menu" )
                                {
                                dialog = $(".BM-title").next();
                                dialog.find("> div").remove();
                                }
                                else if ( where == "append" )
                                {
                                dialog = $(".dialog-BM-append");
                                dialog.find("li").remove();
                                }
                                else if ( where == "edit" )
                                {
                                dialog = $(".dialog-BM-edit");
                                dialog.find("li").remove();
                                
                                dialog.data("BMList", result.replace(/\n/gi, ''));
                                G_BMFolList = G_tempBMFolList = result.replace(/\n/gi, '');
                                }
                                // Append list
                                //                                $.each(BMInfoJson, function(folderName, files) {
                                var resultSplit = result.split("\" : {");
                                for ( var index = 0; index < resultSplit.length - 1; index++ ) {
                                var folderName = resultSplit[index].substring(resultSplit[index].lastIndexOf("\"") + 1);
                                if(folderName != "최근 문서")
                                {
                                if ( where == "menu" )          dialog.append("<div class='BM-folder' onclick='getBMList(this)'><img src='images/icon/nav-folder-03.png'><label>" + folderName + "</label><span></span></div>");
                                else if ( where == "append" )   dialog.find("ul").append("<li ontouchstart onclick=\"appendBM('" + folderName + "')\"><label class='imgLabel'></label><label>" + folderName + "</label></li>");
                                else if ( where == "edit" )     dialog.find("ul").append("<li><img onclick=\"removeBMFolder(this)\"/><img/><label>" + folderName + "</label><img onclick=\"BMEdit_changeFolOrder(this, 'down')\"><img onclick=\"BMEdit_changeFolOrder(this, 'up')\"><input type='button' value='수정' onclick=\"BMFolChangeDialogManager('open', this)\"><span></span></li>");
                                if ( where == "menu" && previousMenu == folderName )    dialog.find("> div:last-child").addClass("BM-selected");
                                //                                       });
                                }
                                }
                                }
                                
                                }, function(){}, GetlocalStorage("UserID"));
    }
}

                                
                                
                                
                                
                                
                                
                                
                                
                                
/* 즐겨찾기 폴더 추가 창 */
function BMFolAppendDialogManager(way) {
    var dialog = $("#NetID_BMFolAppendDialog");
    if ( way == "open" )
    {
        BMEditDialogManager("close");
        $(".blank").on("click", function(){BMFolAppendDialogManager("close");}).show();
        dialog.show();
        dialog.find("input[type=text]").val("").focus();
    }
    else
    {
        $(".blank").off("click").hide();
        dialog.hide();
        BMEditDialogManager("open");
    }
}
                                
// 즐겨찾기 폴더 추가
function appendBMFolder() {
    var folderName = $("#NetID_BMFolAppendDialog").find("input[type=text]").val();
                                try{
                                Entertainment = new Entertainment();
    Entertainment.appendBMFolder(function(result) {
        BMFolAppendDialogManager("close");
        if ( result == "success" )
        {
            appendBMFolderList("menu");
        }
        else if ( result == "exist" )
        {
            navigator.notification.alert("이미 존재하는 폴더명 입니다.", function(){}, "", "확인");
        }
    }, function(){}, GetlocalStorage("id"), folderName);
                                }catch(e){
                                Entertainment.appendBMFolder(function(result) {
                                                             BMFolAppendDialogManager("close");
                                                             if ( result == "success" )
                                                             {
                                                             appendBMFolderList("menu");
                                                             }
                                                             else if ( result == "exist" )
                                                             {
                                                             navigator.notification.alert("이미 존재하는 폴더명 입니다.", function(){}, "", "확인");
                                                             }
                                                             }, function(){}, GetlocalStorage("id"), folderName);
                                }
}

/* 즐겨찾기 폴더명 변경 창 */
function BMFolChangeDialogManager(way, folderName) {
    var dialog = $("#NetID_BMFolChangeDialog");
    if ( way == "open" )
    {
        BMEditDialogManager("close");
        $(".blank").on("click", function(){BMFolChangeDialogManager("close");}).show();
        dialog.show();
        dialog.find("input[type=hidden]").val($(folderName).parent().find("label:nth-child(3)").text());
        dialog.find("input[type=text]").val($(folderName).parent().find("label:nth-child(3)").text()).focus();
    }
    else
    {
        $(".blank").off("click").hide();
        dialog.hide();
        BMEditDialogManager("open");
    }
}

// 즐겨찾기 폴더명 변경
function changeBMFolder() {
    var oldFolderName = $("#NetID_BMFolChangeDialog").find("input[type=hidden]").val();
    var newFolderName = $("#NetID_BMFolChangeDialog").find("input[type=text]").val();
    try{
        Entertainment = new Entertainment();
        Entertainment.changeBMFolder(function(result) {
                                     BMFolChangeDialogManager("close");
                                     if ( result == "success" )
                                     {
                                     var currentFolderName = $(".BM-selected label").text();
                                     previousMenu = oldFolderName == currentFolderName?  newFolderName : currentFolderName;
                                     $("#NetID_currentBMFolder").text(" > " + previousMenu);
                                     appendBMFolderList("menu");
                                     }
                                     else if ( result == "exist" )
                                     {
                                     navigator.notification.alert("이미 존재하는 폴더명 입니다.", function(){}, "", "확인");
                                     }
                                     }, function(){}, GetlocalStorage("id"), oldFolderName, newFolderName);
    } catch(e) {
        Entertainment.changeBMFolder(function(result) {
                                     BMFolChangeDialogManager("close");
                                     if ( result == "success" )
                                     {
                                     var currentFolderName = $(".BM-selected label").text();
                                     previousMenu = oldFolderName == currentFolderName?  newFolderName : currentFolderName;
                                     $("#NetID_currentBMFolder").text(" > " + previousMenu);
                                     appendBMFolderList("menu");
                                     }
                                     else if ( result == "exist" )
                                     {
                                     navigator.notification.alert("이미 존재하는 폴더명 입니다.", function(){}, "", "확인");
                                     }
                                     }, function(){}, GetlocalStorage("id"), oldFolderName, newFolderName);
    }
}

// 즐겨찾기 폴더 삭제
function removeBMFolder(target) {
    var folderName = $(target).parent().find("label:nth-child(3)").text();
    navigator.notification.confirm("'" + folderName + "' 폴더 안의 \n즐겨찾기 파일들이 모두 삭제됩니다. \n계속 진행하시겠습니까?", function(button) {
                                   if ( button == 1)
                                   {
                                   try{
                                   Entertainment = new Entertainment();
                                   Entertainment.removeBMFolder(function() {
                                                                var currentFolderName = $(".BM-selected label").text();
                                                                if ( folderName == currentFolderName )
                                                                {
                                                                appendBMFolderList("menu");
                                                                BMEditDialogManager("close");
                                                                refresh();
                                                                }
                                                                else
                                                                {
                                                                previousMenu = currentFolderName;
                                                                appendBMFolderList("menu");
                                                                appendBMFolderList("edit");
                                                                }
                                                                }, function(){}, GetlocalStorage("id"), folderName);
                                   } catch(e) {
                                   Entertainment.removeBMFolder(function() {
                                                                var currentFolderName = $(".BM-selected label").text();
                                                                if ( folderName == currentFolderName )
                                                                {
                                                                appendBMFolderList("menu");
                                                                BMEditDialogManager("close");
                                                                refresh();
                                                                }
                                                                else
                                                                {
                                                                previousMenu = currentFolderName;
                                                                appendBMFolderList("menu");
                                                                appendBMFolderList("edit");
                                                                }
                                                                }, function(){}, GetlocalStorage("id"), folderName);
                                   }
                                   }
                                   }, "", ["확인", "취소"]);
}

// 즐겨찾기 폴더 편집 창
function BMEditDialogManager(way) {
//    if ( $(".dialog-BM-append").is(":visible") )    BMAppendDialogManager("close", '', '', '');
    var dialog = $(".dialog-BM-edit");
    if ( way == "open" )
    {
        $(".contents-list").css("overflow-y", "hidden");
        $(".blank").on("click", function(){BMEditDialogManager("close");}).show();
        dialog.show();
        appendBMFolderList("edit");
    }
    else
    {
        G_BMFolList = G_tempBMFolList;
        $(".contents-list").css("overflow-y", "scroll");
        $(".blank").off("click").hide();
        dialog.hide();
    }
}
                                
                                var G_BMFolList = "";
                                function BMEdit_changeFolOrder(target, direction) {
                                    //var BMList = $(".dialog-BM-edit").data("BMList");
                                    if ( G_BMFolList == "" )    G_BMFolList = BMList = $(".dialog-BM-edit").data("BMList");
                                    else                        BMList = G_BMFolList;
                                    BMList = BMList.substring(1, BMList.length - 1);
                                    var BMLists = BMList.split("},");
                                    BMLists[BMLists.length - 1] = BMLists[BMLists.length - 1].slice(0, -1);
                                
                                    target = $(target).parent();
                                    direction == "up"?  target.insertBefore(target.prev()) : target.insertAfter(target.next());
                                
                                    target = target.find("label").text();
                                    //alert(BMList);
                                    var result = "{";
                                    var standard;
                                    for ( var index = 0; index < BMLists.length; index++ ) {
                                        standard = direction == "up"?   index + 1 : index;
                                        if ( index < BMLists.length - 1 &&  BMLists[standard].substring(BMLists[standard].indexOf("\"") + 1, BMLists[standard].indexOf("\" :")) == target ) {
                                            result += result == "{"?    BMLists[index + 1] + "}" : "," + BMLists[index + 1] + "}";
                                        }
                                
                                        if ( result.indexOf(BMLists[index]) < 0 )  result += result == "{"?    BMLists[index] + "}" : "," + BMLists[index] + "}";
                                        // alert(result);
                                    }
                                    // result += "}";
                                    G_BMFolList = result + "}";
                                
                                    //alert(G_BMFolList);
                                }



                                function saveBMFolOrder() {
                                if(G_BMFolList == G_tempBMFolList) {
                                    BMEditDialogManager("close");
                                    return;
                                }
                                    navigator.notification.confirm("즐겨찾기함 순서를 변경하시겠습니까?", function(button) {
                                        if ( button == 1 ) {
                                            Entertainment.changeBMFolOrder(function() {
                                                G_tempBMFolList = G_BMFolList;
                                                previousMenu = $(".BM-selected label").text();
                                                appendBMFolderList("menu");
                                                appendBMFolderList("edit");
                                                BMEditDialogManager("close");
                                             }, function(){}, GetlocalStorage("id"), G_BMFolList);
                                         }
                                    }, "", ["확인", "취소"]);
                                }

                                function recentClear(){
                                navigator.notification.confirm("최근 문서 목록을\n초기화 하시겠습니까?", function(button) {
                                                               
                                                               if(button == 1)
                                                               {
                                                               
                                                               try{
                                                               Entertainment = new Entertainment();
                                                               Entertainment.removeBMFolder(function() {
                                                                                            try{
                                                                                            Entertainment = new Entertainment();
                                                                                            Entertainment.appendBMFolder(function(result) {
                                                                                                                         refresh();
                                                                                                                         }, function(){}, GetlocalStorage("id"), "최근 문서");
                                                                                            }catch(e){
                                                                                            Entertainment.appendBMFolder(function(result) {
                                                                                                                         refresh();
                                                                                                                         }, function(){}, GetlocalStorage("id"), "최근 문서");
                                                                                            }
                                                                                            }, function(){}, GetlocalStorage("id"), "최근 문서");
                                                               } catch(e) {
                                                               Entertainment.removeBMFolder(function() {
                                                                                            try{
                                                                                            Entertainment = new Entertainment();
                                                                                            Entertainment.appendBMFolder(function(result) {
                                                                                                                         refresh();
                                                                                                                         }, function(){}, GetlocalStorage("id"), "최근 문서");
                                                                                            }catch(e){
                                                                                            Entertainment.appendBMFolder(function(result) {
                                                                                                                         refresh();
                                                                                                                         }, function(){}, GetlocalStorage("id"), "최근 문서");
                                                                                            }
                                                                                            }, function(){}, GetlocalStorage("id"), "최근 문서");
                                                               }
                                                               
                                                               }
                                                               else
                                                               {
                                                               return;
                                                               }
                                                               
                                                               }, "", ["확인", "취소"]);
                                }

