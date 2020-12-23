//
//  EntertainmentPlugin.m
//  CECMPad
//
//  Created by 넷아이디 on 12. 7. 16..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EntertainmentPlugin.h"
#import "Util.h"
#import "Entertainment.h"

@implementation EntertainmentPlugin
@synthesize callbackID;
//
//- (void) Photo:(NSMutableArray*)arguments withDict: (NSMutableDictionary*)options{
//    self.callbackID = [arguments pop];
//    
//    Entertainment *ent = [[Entertainment alloc] init];
//    [ent GetPhoto];
//    NSString *platform = @"11\t";
//    NSString *DeviceID = [[UIDevice currentDevice] uniqueIdentifier];
//    platform = [platform stringByAppendingFormat:DeviceID];
//    
//    NSMutableString *stringToReturn = [NSMutableString stringWithString:platform];
//    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
//    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
//}
//
//- (void) Video:(NSMutableArray*)arguments withDict: (NSMutableDictionary*)options{
//    self.callbackID = [arguments pop];
//    
//    NSString *platform = @"11\t";
//    NSString *DeviceID = [[UIDevice currentDevice] uniqueIdentifier];
//    platform = [platform stringByAppendingFormat:DeviceID];
//    
//    NSMutableString *stringToReturn = [NSMutableString stringWithString:platform];
//    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
//    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
//}

- (void) Gallery:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options{
//    self.callbackID = [arguments pop];
//    self.callbackID = [arguments objectAtIndex:0];
    self.callbackID = self.callbackID;
    
    NSString *srcPath = [arguments objectAtIndex:1];
    NSString *FileName = [arguments objectAtIndex:3];
    NSString *CurrentPath = [arguments objectAtIndex:2];
    NSString *CameraFlag = [arguments objectAtIndex:4];
    NSLog(@"File is %@", srcPath);
    NSLog(@"FileName is %@", FileName);
    NSLog(@"CurrentPath is %@", CurrentPath);
    
    NSString *dstPath;
    dstPath = [CurrentPath stringByAppendingFormat:@"/"];
    dstPath = [dstPath stringByAppendingFormat:FileName];
    NSLog(@"dstPath is %@", dstPath);
    BOOL bStat = YES;
    NSArray *tmpFileName;
    NSString *tmpFile;
    NSFileManager *fileMgr = [NSFileManager defaultManager];

    NSDate *now = [[NSDate alloc]init];
    
    NSDateFormatter *timeFormat = [[[NSDateFormatter alloc] init] autorelease];
    [timeFormat setDateFormat:@"HHmmss"];
    NSString *theTime = [timeFormat stringFromDate:now];
    NSLog(@"theTime is %@", timeFormat);
    
    if([CameraFlag isEqualToString:@"camera"]){
        if ([fileMgr fileExistsAtPath:srcPath])
        {
            if ([srcPath isEqualToString:dstPath])
            {
                //return YES;
            }
            
            if ([fileMgr fileExistsAtPath:dstPath])
            {
                tmpFileName = [FileName componentsSeparatedByString:@"."];
                tmpFile = [[tmpFileName objectAtIndex:0] stringByAppendingFormat:theTime];
                tmpFile = [tmpFile stringByAppendingFormat:@"."];
                FileName = [tmpFile stringByAppendingFormat:[tmpFileName objectAtIndex:1]];
                dstPath = [CurrentPath stringByAppendingFormat:@"/"];
                dstPath = [dstPath stringByAppendingFormat:FileName];
               // bStat =[fileMgr removeItemAtPath:dstPath  error: NULL];
            }
            bStat = [fileMgr moveItemAtPath:srcPath toPath:dstPath error: NULL];
        }
    }
    else{
        if ([fileMgr fileExistsAtPath:srcPath])
        {
            if ([fileMgr fileExistsAtPath:dstPath])
            {
                tmpFileName = [FileName componentsSeparatedByString:@"."];
                tmpFile = [[tmpFileName objectAtIndex:0] stringByAppendingFormat:theTime];
                tmpFile = [tmpFile stringByAppendingFormat:@"."];
                FileName = [tmpFile stringByAppendingFormat:[tmpFileName objectAtIndex:1]];
                dstPath = [CurrentPath stringByAppendingFormat:@"/"];
                dstPath = [dstPath stringByAppendingFormat:FileName];
                //bStat = [fileMgr removeItemAtPath:dstPath  error: nil];
            }
            
            bStat = [fileMgr copyItemAtPath:srcPath toPath:dstPath error: nil];
        }
    }
    
    NSMutableString *stringToReturn = [NSMutableString stringWithString:dstPath];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackID];
    
}

- (void) readFile : (CDVInvokedUrlCommand*)command {
    self.callbackID = command.callbackId;
    NSString *user = [command.arguments objectAtIndex:0];
    NSString *returnString = @"";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    
    //make a file name to write the data to using the documents directory:
    NSString *originalF = [NSString stringWithFormat:@"%@/%@.txt", documentsDirectory, user];
    
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:originalF isDirectory:&isDir];
    if (exists) {
        NSLog(@"Favor Exists File");
    } else {
        NSLog(@"Favor Not Exists File");
    }
    NSLog(@"originalF Path = %@", originalF);
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:originalF];
    if(!fileExists) {
        NSMutableString *stringToReturn = [NSMutableString stringWithString:returnString];

        NSArray *paths = NSSearchPathForDirectoriesInDomains
        (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        //make a file name to write the data to using the documents directory:
        NSString *originalF = [NSString stringWithFormat:@"%@/%@.txt", documentsDirectory, user];
        NSString *tempF = [NSString stringWithFormat:@"%@/%@.tmp", documentsDirectory, user];
        [@"" writeToFile:tempF atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
        
        MutableOrderedDictionary *originalBM = [[MutableOrderedDictionary alloc] init];
        MutableOrderedDictionary *BMList = [[MutableOrderedDictionary alloc] init];
        originalBM = [MutableOrderedDictionary dictionaryWithContentsOfFile:originalF];
        
        if(originalBM){
            BOOL flag1 = false;
            BOOL flag2 = false;
            for (id key in originalBM) {
                if([key isEqualToString:@"즐겨찾기"]) flag1 = true;
                if([key isEqualToString:@"최근 문서"]) flag2 = true;
            }
            if(flag1 && flag2)
            {
                returnString = @"exist";
                NSMutableString *stringToReturn = [NSMutableString stringWithString:returnString];
                
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                return;
            }
            
            if(flag1) [originalBM setObject:BMList forKey:@"즐겨찾기"];
            if(flag2) [originalBM setObject:BMList forKey:@"최근 문서"];
            //            NSLog(@"originalBM2 = %@", originalBM);
            [originalBM writeToFile:tempF atomically:YES];
        } else {
            NSLog(@"empty -> create BM folder : %@", @"즐겨찾기, 최근 문서");
            MutableOrderedDictionary* BMList = [[MutableOrderedDictionary alloc] init];
            MutableOrderedDictionary* BMFol = [[MutableOrderedDictionary alloc] init];
            [BMList setObject:BMFol forKey:@"즐겨찾기"];
            [BMList setObject:BMFol forKey:@"최근 문서"];
            
            NSLog(@"%@", BMList);
            
            [BMList writeToFile:tempF atomically:YES];
        }

        [[NSFileManager defaultManager] removeItemAtPath:originalF error:nil];
        [[NSFileManager defaultManager] moveItemAtPath:tempF toPath:originalF error:nil];

        originalBM = [MutableOrderedDictionary dictionaryWithContentsOfFile:originalF];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:originalBM
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        NSString *jsonString;
        
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        returnString = jsonString;
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    MutableOrderedDictionary *originalBM = [[MutableOrderedDictionary alloc] init];
    originalBM = [MutableOrderedDictionary dictionaryWithContentsOfFile:originalF];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:originalBM
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString;

    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    returnString = jsonString;
    
    NSLog(@"json returnString = %@", jsonString);

    NSMutableString *stringToReturn = [NSMutableString stringWithString:returnString];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

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
- (void) appendBookmark : (CDVInvokedUrlCommand*)command{
    self.callbackID = command.callbackId;
    NSString *returnString = @"";
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
    NSString *month = @"";
    NSString *day = @"";
    NSString *hour = @"";
    NSString *minute = @"";
    NSString *second = @"";
    if([nsDateComponents month] < 10) {
        month = @"0";
        month = [month stringByAppendingString:[@((long)[nsDateComponents month]) stringValue]];
    } else {
        month = [month stringByAppendingString:[@((long)[nsDateComponents month]) stringValue]];
    }
    if([nsDateComponents day] < 10) {
        day = @"0";
        day = [day stringByAppendingString:[@((long)[nsDateComponents day]) stringValue]];
    } else {
        day = [day stringByAppendingString:[@((long)[nsDateComponents day]) stringValue]];
    }
    if([nsDateComponents hour] < 10) {
        hour = @"0";
        hour = [hour stringByAppendingString:[@((long)[nsDateComponents hour]) stringValue]];
    } else {
        hour = [hour stringByAppendingString:[@((long)[nsDateComponents hour]) stringValue]];
    }
    if([nsDateComponents minute] < 10) {
        minute = @"0";
        minute = [minute stringByAppendingString:[@((long)[nsDateComponents minute]) stringValue]];
    } else {
        minute = [minute stringByAppendingString:[@((long)[nsDateComponents minute]) stringValue]];
    }
    if([nsDateComponents second] < 10) {
        second = @"0";
        second = [second stringByAppendingString:[@((long)[nsDateComponents second]) stringValue]];
    } else {
        second = [second stringByAppendingString:[@((long)[nsDateComponents second]) stringValue]];
    }
    currentTime = [currentTime stringByAppendingString:[@((long)[nsDateComponents year]) stringValue]];
    currentTime = [currentTime stringByAppendingString:month];
    currentTime = [currentTime stringByAppendingString:day];
    currentTime = [currentTime stringByAppendingString:hour];
    currentTime = [currentTime stringByAppendingString:minute];
    currentTime = [currentTime stringByAppendingString:second];
    
    NSLog(@"currentTime = %@", currentTime);
    /****************************/
    
    fileInfo = [fileInfo stringByAppendingString:currentTime];
    fileInfo = [fileInfo stringByAppendingString:@"\t"];
    
    NSRange subRange = [path rangeOfString:@"/"];
    if(subRange.location == NSNotFound) {
        NSLog(@"/ 는 찾을 수 없습니다.");
    }
    else {
//        NSLog(@"/ 를 인덱스 %lu(길이 %lu) 에서 발견함!", subRange.location, subRange.length);
    }
    fileInfo = [fileInfo stringByAppendingString:[path substringFromIndex:subRange.location]];
    fileInfo = [fileInfo stringByAppendingString:@"\t"];
    fileInfo = [fileInfo stringByAppendingString:getFileInfo];
    
    NSLog(@"fileInfo = %@", fileInfo);

    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    
    //make a file name to write the data to using the documents directory:
    NSString *originalF = [NSString stringWithFormat:@"%@/%@.txt", documentsDirectory, user];
    NSString *tempF = [NSString stringWithFormat:@"%@/%@.tmp", documentsDirectory, user];
    
    NSLog(@"fav file path = %@", originalF);
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:originalF];
    if(!fileExists) [@"" writeToFile:originalF atomically:YES encoding:NSStringEncodingConversionAllowLossy error:nil];
    [@"" writeToFile:tempF atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    MutableOrderedDictionary *originalBM = [[MutableOrderedDictionary alloc] init];
    originalBM = [MutableOrderedDictionary dictionaryWithContentsOfFile:originalF];
    
    if([originalBM count]){
        MutableOrderedDictionary *BMFol = [[MutableOrderedDictionary alloc] init];
        NSLog(@"OriginalBM = %@", originalBM);
        for (id key in [originalBM valueForKey:folderName]) {
            [BMFol setObject:[[originalBM valueForKey:folderName] objectForKey:key] forKey:key];
            if([key isEqualToString:path]){
                NSLog(@"exist!");
                returnString = @"exist";
                NSMutableString *stringToReturn = [NSMutableString stringWithString:returnString];
                
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                return;
            }
        }
        NSLog(@"Not Exist!");
        if(!BMFol) {
            NSLog(@"init BMFol");
            BMFol = [[MutableOrderedDictionary alloc] init];
        }
        
        [BMFol setObject:fileInfo forKey:path];
        
        [originalBM setObject:BMFol forKey:folderName];
        NSLog(@"OriginalBM = %@", originalBM);
        [originalBM writeToFile:tempF atomically:YES];
    } else {
        NSLog(@"empty BM");
        MutableOrderedDictionary* BMList = [[MutableOrderedDictionary alloc] init];
        MutableOrderedDictionary* BMFol = [[MutableOrderedDictionary alloc] init];
        [BMFol setObject:fileInfo forKey:path];
        [BMList setObject:BMFol forKey:folderName];
        
        NSLog(@"%@", BMList);
        
        [BMList writeToFile:tempF atomically:YES];
    }
    [[NSFileManager defaultManager] removeItemAtPath:originalF error:nil];
    [[NSFileManager defaultManager] moveItemAtPath:tempF toPath:originalF error:nil];
    
    NSLog(@"read file : %@", [MutableOrderedDictionary dictionaryWithContentsOfFile:originalF]);
    
    returnString = @"success";
    
    NSMutableString *stringToReturn = [NSMutableString stringWithString:returnString];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * 즐겨찾기 변경(사용자 정렬)
 *
 * @param user          즐겨찾기 내용보관 파일명을 위한 값
 * @param folderName   즐겨찾기 추가할 대상 폴더
 * @param fileInfo      파일 정보들
 * @return            성공, 실패
 */
- (void) changeBookmark : (CDVInvokedUrlCommand*)command{
    self.callbackID = command.callbackId;
    NSString *returnString = @"";
    NSString *user = [command.arguments objectAtIndex:0];
    NSString *folderName = [command.arguments objectAtIndex:1];
    NSString *fileInfo = [command.arguments objectAtIndex:2];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    
    //make a file name to write the data to using the documents directory:
    NSString *originalF = [NSString stringWithFormat:@"%@/%@.txt", documentsDirectory, user];
    NSString *tempF = [NSString stringWithFormat:@"%@/%@.tmp", documentsDirectory, user];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:originalF];
    if(!fileExists) [@"" writeToFile:originalF atomically:YES encoding:NSStringEncodingConversionAllowLossy error:nil];
    [@"" writeToFile:tempF atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    MutableOrderedDictionary *originalBM = [MutableOrderedDictionary dictionaryWithContentsOfFile:originalF];
    
    MutableOrderedDictionary* BMFol = [[MutableOrderedDictionary alloc] init];
    
    // String[] tempFileInfo = fileInfo.replace("\\t", "\t").split("\"");   // 파일로부터 읽은 즐겨찾기 파일정보들을 원래대로 복구 (* JSON을 파일에 write할 경우, \t는 문자로 기입되며, "는 \"로 입력됨
    fileInfo = [fileInfo stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"];
    NSArray *token = [fileInfo componentsSeparatedByString: @"\""];
    
    for(int i = 1; i < [token count]-1; i+=4){
        [BMFol setObject:token[i+2] forKey:token[i]];
    }
    NSLog(@"changeBM BMFol = %@", BMFol);

    [originalBM setObject:BMFol forKey:folderName];


    [originalBM writeToFile:tempF atomically:YES];
    
    [[NSFileManager defaultManager] removeItemAtPath:originalF error:nil];
    [[NSFileManager defaultManager] moveItemAtPath:tempF toPath:originalF error:nil];
    
    returnString = @"success";

    NSMutableString *stringToReturn = [NSMutableString stringWithString:returnString];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
//
///**
// * 즐겨찾기 제거
// *
// * @param user         즐겨찾기 내용보관 파일명을 위한 값
// * @param folderName    즐겨찾기 추가할 대상 폴더
// * @param path         파일 정보들
// * @return            성공, 실패
// */
- (void) removeBookmark : (CDVInvokedUrlCommand*)command{
    self.callbackID = command.callbackId;
    NSString *returnString = @"";
    NSString *user = [command.arguments objectAtIndex:0];
    NSString *folderName = [command.arguments objectAtIndex:1];
    NSString *path = [command.arguments objectAtIndex:2];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *originalF = [NSString stringWithFormat:@"%@/%@.txt", documentsDirectory, user];
    NSString *tempF = [NSString stringWithFormat:@"%@/%@.tmp", documentsDirectory, user];
    [@"" writeToFile:tempF atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    MutableOrderedDictionary *originalBM = [[MutableOrderedDictionary alloc] init];
    originalBM = [MutableOrderedDictionary dictionaryWithContentsOfFile:originalF];
    
    MutableOrderedDictionary *BMFol = [[MutableOrderedDictionary alloc] init];
    
    for (id key in [originalBM valueForKey:folderName]) {
        [BMFol setObject:[[originalBM valueForKey:folderName] objectForKey:key] forKey:key];
    }
    
    NSLog(@"BMFol1 = %@", BMFol);
    [BMFol removeObjectForKey:path];
    [originalBM setObject:BMFol forKey:folderName];
    NSLog(@"BMFol2 = %@", BMFol);
    [originalBM writeToFile:tempF atomically:YES];
    
    [[NSFileManager defaultManager] removeItemAtPath:originalF error:nil];
    [[NSFileManager defaultManager] moveItemAtPath:tempF toPath:originalF error:nil];
    
    returnString = @"success";

    NSMutableString *stringToReturn = [NSMutableString stringWithString:returnString];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
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

- (void) appendBMFolder : (CDVInvokedUrlCommand*)command{
    self.callbackID = command.callbackId;
    NSString *user = [command.arguments objectAtIndex:0];
    NSString *folderName = [command.arguments objectAtIndex:1];
    NSString *returnString = @"";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *originalF = [NSString stringWithFormat:@"%@/%@.txt", documentsDirectory, user];
    NSString *tempF = [NSString stringWithFormat:@"%@/%@.tmp", documentsDirectory, user];
    [@"" writeToFile:tempF atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    MutableOrderedDictionary *originalBM = [[MutableOrderedDictionary alloc] init];
    MutableOrderedDictionary *BMList = [[MutableOrderedDictionary alloc] init];
    originalBM = [MutableOrderedDictionary dictionaryWithContentsOfFile:originalF];
    NSLog(@"originalF = %@", originalF);
    NSLog(@"tempF = %@", tempF);
    NSLog(@"originalBM1 = %@", originalBM);
    
    if(originalBM){
        for (id key in originalBM) {
            if([key isEqualToString:folderName]) {
                returnString = @"exist";
                NSMutableString *stringToReturn = [NSMutableString stringWithString:returnString];
                
                CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                return;
            }
        }
        [originalBM setObject:BMList forKey:folderName];
        NSLog(@"originalBM2 = %@", originalBM);
        [originalBM writeToFile:tempF atomically:YES];
    } else {
        NSLog(@"empty -> create BM folder : %@", folderName);
        MutableOrderedDictionary* BMList = [[MutableOrderedDictionary alloc] init];
        MutableOrderedDictionary* BMFol = [[MutableOrderedDictionary alloc] init];
        [BMList setObject:BMFol forKey:folderName];
        
        NSLog(@"%@", BMList);
        
        [BMList writeToFile:tempF atomically:YES];
    }
    NSError* err = nil;
    NSError* err2 = nil;
    [[NSFileManager defaultManager] removeItemAtPath:originalF error:nil];
    [[NSFileManager defaultManager] moveItemAtPath:tempF toPath:originalF error:nil];
    NSLog(@"err = %@", err.localizedDescription);
    NSLog(@"err2 = %@", err2.localizedDescription);
//    NSLog(@"originalF = %@", originalF);

    returnString = @"success";

    NSMutableString *stringToReturn = [NSMutableString stringWithString:returnString];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) changeBMFolder : (CDVInvokedUrlCommand*)command{
    self.callbackID = command.callbackId;
    NSString *user = [command.arguments objectAtIndex:0];
    NSString *oldFolderName = [command.arguments objectAtIndex:1];
    NSString *newFolderName = [command.arguments objectAtIndex:2];
    NSString *returnString = @"";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *originalF = [NSString stringWithFormat:@"%@/%@.txt", documentsDirectory, user];
    NSString *tempF = [NSString stringWithFormat:@"%@/%@.tmp", documentsDirectory, user];
    [@"" writeToFile:tempF atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    MutableOrderedDictionary *originalBM = [[MutableOrderedDictionary alloc] init];
    MutableOrderedDictionary *BMList = [[MutableOrderedDictionary alloc] init];
    MutableOrderedDictionary *tempBMList = [[MutableOrderedDictionary alloc] init];
    originalBM = [MutableOrderedDictionary dictionaryWithContentsOfFile:originalF];
    BMList = [MutableOrderedDictionary dictionaryWithContentsOfFile:originalF];
    for (id key in originalBM) {
        if([key isEqualToString:newFolderName]){
            returnString = @"exist";
            break;
        }
        if([key isEqualToString:oldFolderName]){
            [tempBMList setObject:[BMList objectForKey:key] forKey:newFolderName];
            continue;
        }
        [tempBMList setObject:[BMList objectForKey:key] forKey:key];
    }
    
    BMList = tempBMList;
    if([returnString isEqualToString:@"exist"]){
        NSMutableString *stringToReturn = [NSMutableString stringWithString:returnString];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        [BMList writeToFile:tempF atomically:YES];
        
        [[NSFileManager defaultManager] removeItemAtPath:originalF error:nil];
        [[NSFileManager defaultManager] moveItemAtPath:tempF toPath:originalF error:nil];
        
        returnString = @"success";
        
        NSMutableString *stringToReturn = [NSMutableString stringWithString:returnString];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void) removeBMFolder : (CDVInvokedUrlCommand*)command{
    self.callbackID = command.callbackId;
    NSString *user = [command.arguments objectAtIndex:0];
    NSString *folderName = [command.arguments objectAtIndex:1];
    NSString *returnString = @"";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *originalF = [NSString stringWithFormat:@"%@/%@.txt", documentsDirectory, user];
    NSString *tempF = [NSString stringWithFormat:@"%@/%@.tmp", documentsDirectory, user];
    [@"" writeToFile:tempF atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    MutableOrderedDictionary *originalBM = [[MutableOrderedDictionary alloc] init];
    MutableOrderedDictionary *BMList = [[MutableOrderedDictionary alloc] init];
    originalBM = [MutableOrderedDictionary dictionaryWithContentsOfFile:originalF];
    
    [originalBM removeObjectForKey:folderName];
    
    [originalBM writeToFile:tempF atomically:YES];
    
    [[NSFileManager defaultManager] removeItemAtPath:originalF error:nil];
    [[NSFileManager defaultManager] moveItemAtPath:tempF toPath:originalF error:nil];
//    try {
//        File pf = this.cordova.getActivity().getExternalFilesDir("");
//        File originalF = new File(pf.getAbsolutePath() + "/" + user + ".txt");
//        File tempF = new File(originalF.getAbsolutePath() + ".tmp");
//        tempF.createNewFile();
//        
//        String originalBM = readFile(originalF);
//        JSONObject BMList = new JSONObject(originalBM);
//        BMList.remove(folderName);
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
    
    
    
    returnString = @"success";
    
    NSMutableString *stringToReturn = [NSMutableString stringWithString:returnString];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) changeBMFolOrder : (CDVInvokedUrlCommand*)command{
    self.callbackID = command.callbackId;
    NSString *user = [command.arguments objectAtIndex:0];
    NSString *BMList = [command.arguments objectAtIndex:1];
    NSString *returnString = @"";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *originalF = [NSString stringWithFormat:@"%@/%@.txt", documentsDirectory, user];
    NSString *tempF = [NSString stringWithFormat:@"%@/%@.tmp", documentsDirectory, user];
    
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:originalF isDirectory:&isDir];
    if (exists) {
        NSLog(@"Favor Exists File");
    } else {
        NSLog(@"Favor Not Exists File");
    }
    NSLog(@"originalF Path = %@", originalF);
    
    
    MutableOrderedDictionary *originalBM = [[MutableOrderedDictionary alloc] init];
    MutableOrderedDictionary *tempBM = [[MutableOrderedDictionary alloc] init];
    
    originalBM = [MutableOrderedDictionary dictionaryWithContentsOfFile:originalF];
    
//    tempBM = [MutableOrderedDictionary dictionaryWithContentsOfFile:originalF];
//    [tempBM writeToFile:tempF atomically:YES];
    
    
    NSLog(@"originalBM = %@", originalBM);
    
    BMList = [BMList substringToIndex:[BMList length] - 5];
    BMList = [BMList substringFromIndex:2];
    BMList = [BMList stringByReplacingOccurrencesOfString:@"\":{}," withString:@""];
    NSArray *token = [BMList componentsSeparatedByString: @"\""];
    
    for( int i = 0; i < token.count; i++){
        for(id key in originalBM)
        {
            if([token[i] isEqualToString:key]){
                [tempBM setObject:[originalBM objectForKey:key] forKey:key];
            }
        }
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:originalF error:nil];
//    [tempBM writeToFile:originalF atomically:YES];
    [@"" writeToFile:originalF atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    [tempBM writeToFile:originalF atomically:YES];
    
    MutableOrderedDictionary *originalBM2 = [[MutableOrderedDictionary alloc] init];
    originalBM2 = [MutableOrderedDictionary dictionaryWithContentsOfFile:originalF];
    
    NSLog(@"originalBM2 = %@", originalBM2);
    
    returnString = @"success";
    
    NSMutableString *stringToReturn = [NSMutableString stringWithString:returnString];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}



@end
