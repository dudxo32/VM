//
//  Entertainment.m
//  CECMPad
//
//  Created by 넷아이디 on 12. 7. 16..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Entertainment.h"

@implementation Entertainment 
@synthesize callbackID;

- (void) GetPhoto{
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    [self presentModalViewController:picker animated:YES];
//    [picker release];
}






/**
 * 파일 내용 읽어들이기
 *
 * @param f      읽어들일 파일
 * @return      파일 내용
 */
//- (void) readFile : (CDVInvokedUrlCommand*)command {
//    self.callbackID = command.callbackId;
//    NSString *stringObtainedFromJavascript = [command.arguments objectAtIndex:0];
//    NSString *result = "";
//    if ( [f ] ) return result;
//    
//    try {
//        StringBuilder readLine = new StringBuilder();
//        FileReader fr = new FileReader(f);
//        BufferedReader br = new BufferedReader(fr);
//        String line;
//        
//        while ( (line = br.readLine()) != null ) {
//            readLine.append(line);
//        }
//        br.close();
//        fr.close();
//        result = readLine.toString();
//    } catch (Exception e) {
//        e.printStackTrace();
//    }
//    
//    return result;
//    
//    
//    NSMutableString *stringToReturn = [NSMutableString stringWithString:cryptPara];
//    
//    //CDVPluginResult* pluginResult = [pluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[stringToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
//    //    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//}

/**
 * 즐겨찾기 추가
 *
 * @param user          즐겨찾기 내용보관 파일명을 위한 값
 * @param folderName    즐겨찾기 추가할 대상 폴더
 * @param path          추가 파일 서버경로
 * @param fileInfo      파일 정보들
 * @return            success: 아무 오류 없음
 *                   exist: 이미 해당 폴더에 해당 파일이 있음
 *                   fail: 뭔가 오류
 */
//private String appendBookmark(String user, String folderName, String path, String fileInfo) {
- (void) appendBookmark : (CDVInvokedUrlCommand*)command{
    self.callbackID = command.callbackId;
    NSString *user = [command.arguments objectAtIndex:0];
    NSString *folderName = [command.arguments objectAtIndex:1];
    NSString *path = [command.arguments objectAtIndex:2];
    NSString *getFileInfo = [command.arguments objectAtIndex:3];
    
    NSString *fileInfo = @"";
    
    NSDate *nsDate = [NSDate date];
    NSCalendar *nsCalendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *nsDateComponents = [nsCalendar components:unitFlags fromDate:nsDate];
    
    /***** Get current time *****/
    NSString *currentTime = @"";
    [currentTime stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)[nsDateComponents year]]];
    [currentTime stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)[nsDateComponents day]]];
    [currentTime stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)[nsDateComponents month]]];
    [currentTime stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)[nsDateComponents hour]]];
    [currentTime stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)[nsDateComponents minute]]];
    [currentTime stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)[nsDateComponents second]]];

    NSLog(@"currentTime = %@", currentTime);
    /****************************/

    [fileInfo stringByAppendingString:currentTime];
    [fileInfo stringByAppendingString:@"\t"];
    [fileInfo stringByAppendingString:currentTime];
    
    NSRange subRange = [path rangeOfString:@"/"];
    if(subRange.location == NSNotFound) {
        NSLog(@"/ 는 찾을 수 없습니다.");
    }
    else {
        NSLog(@"/ 를 인덱스 %lu(길이 %lu) 에서 발견함!",
              subRange.location, subRange.length);
    }
    
//    fileInfo = currentTime + "\t" + path.substring(path.indexOf('/')) + "\t" + fileInfo;
//    
//    try {
//        /** 기존 내용 + 새로운 내용을 임시파일(tempF)에 추가
//         *  기존파일(originalF) 제거
//         *  임시파일명을 기존파일명으로 변경
//         */
//        File pf = this.cordova.getActivity().getExternalFilesDir("");
//        File originalF = new File(pf.getAbsolutePath() + "/" + user + ".txt");
//        File tempF = new File(originalF.getAbsolutePath() + ".tmp");
//        if ( !originalF.exists() )   originalF.createNewFile();
//        tempF.createNewFile();
//        
//        String originalBM = readFile(originalF);
//        if ( !"".equals(originalBM) )   // 추가하는 대상 폴더가 존재할 경우
//        {
//            JSONObject BMList = new JSONObject(originalBM);   // 기존 파일 읽어들여서 JSON객체로 생성
//            JSONObject BMFol = getBMFolder(folderName, BMList);   // 기존 즐겨찾기 파일들을 담고있는 폴더를 JSON객체로 생성
//            /************ 이미 존재하는 즐겨찾기인지 검사 ************/
//            Iterator<?> keys = BMFol.keys();
//            
//            while( keys.hasNext() ) {
//                if ( keys.next().toString().equals(path) )   return "exist";
//            }
//            /*****************************************************/
//            BMFol.put(path, fileInfo);   // Key: 파일 경로, Value: 파일 열람을 위한 정보들
//            
//            FileWriter fw = new FileWriter(tempF, true);
//            fw.write(BMList.toString());
//            fw.flush();
//            fw.close();
//        }
//        else   // 추가하는 대상 폴더가 존재하지 않을 경우
//        {
//            JSONObject BMList = new JSONObject();
//            JSONObject BMFol = new JSONObject();
//            BMFol.put(path, fileInfo);
//            BMList.put(folderName, BMFol);
//            
//            FileWriter fw = new FileWriter(tempF, true);
//            fw.write(BMList.toString());
//            fw.flush();
//            fw.close();
//        }
//        
//        while ( originalF.delete() );
//        while ( tempF.renameTo(originalF) );
//    } catch(Exception e) {
//        e.printStackTrace();
//        return "fail";
//    }
//    
//    return "success";
//    
//    NSMutableString *stringToReturn = [NSMutableString stringWithString:cryptPara];
//    
//    //CDVPluginResult* pluginResult = [pluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[stringToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
//    //    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * 즐겨찾기 변경(사용자 정렬)
 *
 * @param user          즐겨찾기 내용보관 파일명을 위한 값
 * @param folderName   즐겨찾기 추가할 대상 폴더
 * @param fileInfo      파일 정보들
 * @return            성공, 실패
 */
//private boolean changeBookmark(String user, String folderName, String fileInfo) {
//- (void) changeBookmark : (CDVInvokedUrlCommand*)command{
//    self.callbackID = command.callbackId;
//    NSString *stringObtainedFromJavascript = [command.arguments objectAtIndex:0];
//    try {
//        File pf = this.cordova.getActivity().getExternalFilesDir("");
//        File originalF = new File(pf.getAbsolutePath() + "/" + user + ".txt");
//        File tempF = new File(originalF.getAbsolutePath() + ".tmp");
//        if ( !originalF.exists() )   originalF.createNewFile();
//        tempF.createNewFile();
//        
//        String originalBM = readFile(originalF);
//        JSONObject BMList = new JSONObject(originalBM);
//        JSONObject files = new JSONObject();
//        String[] tempFileInfo = fileInfo.replace("\\t", "\t").split("\"");   // 파일로부터 읽은 즐겨찾기 파일정보들을 원래대로 복구 (* JSON을 파일에 write할 경우, \t는 문자로 기입되며, "는 \"로 입력됨
//        for ( int c = 1; c < tempFileInfo.length; c+=4 ) { files.put(tempFileInfo[c], tempFileInfo[c+2]); }   // 즐겨찾기 파일들을 대상 폴더 Value(JSON)에 추가
//        BMList.put(folderName, files);   // 해당 폴더를 원래 즐겨찾기 목록에 overwrite
//        
//        FileWriter fw = new FileWriter(tempF, true);
//        fw.write(BMList.toString());
//        fw.flush();
//        fw.close();
//        
//        while ( originalF.delete() );
//        while ( tempF.renameTo(originalF) );
//    } catch(Exception e) {
//        e.printStackTrace();
//        return false;
//    }
//    
//    return true;
//    
//    NSMutableString *stringToReturn = [NSMutableString stringWithString:cryptPara];
//    
//    //CDVPluginResult* pluginResult = [pluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[stringToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
//    //    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//}
//
///**
// * 즐겨찾기 제거
// *
// * @param user         즐겨찾기 내용보관 파일명을 위한 값
// * @param folderName    즐겨찾기 추가할 대상 폴더
// * @param path         파일 정보들
// * @return            성공, 실패
// */
////private boolean removeBookmark(String user, String folderName, String path) {
//- (void) removeBookmark : (CDVInvokedUrlCommand*)command{
//    self.callbackID = command.callbackId;
//    NSString *stringObtainedFromJavascript = [command.arguments objectAtIndex:0];
//    try {
//        File pf = this.cordova.getActivity().getExternalFilesDir("");
//        File originalF = new File(pf.getAbsolutePath() + "/" + user + ".txt");
//        File tempF = new File(originalF.getAbsolutePath() + ".tmp");
//        tempF.createNewFile();
//        
//        String originalBM = readFile(originalF);
//        JSONObject BMList = new JSONObject(originalBM);
//        JSONObject BMFol = getBMFolder(folderName, BMList);
//        BMFol.remove(path);
//        
//        FileWriter fw = new FileWriter(tempF, true);
//        fw.write(BMList.toString());
//        fw.flush();
//        fw.close();
//        
//        while ( originalF.delete() );
//        while ( tempF.renameTo(originalF) );
//    } catch(Exception e) {
//        e.printStackTrace();
//        return false;
//    }
//    
//    return true;
//    
//    NSMutableString *stringToReturn = [NSMutableString stringWithString:cryptPara];
//    
//    //CDVPluginResult* pluginResult = [pluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[stringToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
//    //    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//}
//
///**
// * 총괄 즐겨찾기 목록객체(json)으로부터 특정 폴더 목록객체(json)을 가져오기
// *
// * @param parentPath    가져올 특정 폴더 명
// * @param json          총괄 즐겨찾기 목록객체
// * @return            특정 폴더 json객체
// */
////private JSONObject getBMFolder(String parentPath, JSONObject json) {
//- (void) getBMFolder : (NSString*) parentPath, (NSjs){
//
//    try {
//        String topPath = parentPath.contains("/")?   parentPath.substring(0, parentPath.indexOf("/")) : "", key;
//        Iterator keys = json.keys();
//        
//        // Search BMorite destination folder
//        while ( keys.hasNext() ) {
//            key = (String) keys.next();
//            
//            if ( !"".equals(topPath) )
//            {   // 재귀함수 이용, 하위폴더 존재시 재호출
//                if ( key.equals(topPath) )   return getBMFolder(parentPath.substring(parentPath.indexOf(topPath) + topPath.length() + 1), json.getJSONObject(key));
//            }
//            else
//            {
//                if ( key.equals(parentPath) )   return json.getJSONObject(key);
//            }
//        }
//        
//        // If not exist folder, create and return
//        String[] paths = parentPath.split("/");
//        for ( int index = 0; index < paths.length; index++ ) {
//            json.put(paths[index], new JSONObject());
//            json = json.getJSONObject(paths[index]);
//        }
//    } catch(Exception e) {
//        e.printStackTrace();
//    }
//    
//    return json;
//    
//    NSMutableString *stringToReturn = [NSMutableString stringWithString:cryptPara];
//    
//    //CDVPluginResult* pluginResult = [pluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[stringToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
//    //    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//}

@end
