//
//  CryptUtilPlugin.m
//  ECM_Tablet
//
//  Created by 넷아이디 on 11. 12. 20..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CryptUtilPlugin.h"
#import "FileUtil.h"
#import "ReceiveDataViewController.h"

FileUtil				*g_FileUtil;
@implementation CryptUtilPlugin
@synthesize callbackID;
// 로그인 파라미터 암호화
- (void) login:(CDVInvokedUrlCommand*)command{
    //self.callbackID = [arguments pop];
//    self.callbackID = [command.arguments objectAtIndex:0];
    self.callbackID = command.callbackId;
    NSString *stringObtainedFromJavascript = [command.arguments objectAtIndex:0];
    NSLog(@"stringObtainedFromJavascript is %@", stringObtainedFromJavascript);
    NSString *strkey = [command.arguments objectAtIndex:1];
    //NSLog(@"strkey is %@", strkey);
    NSArray *arrayItems = [stringObtainedFromJavascript componentsSeparatedByString:@"\t"];

    //[self getlogoimg:[arrayItems objectAtIndex:1]with:[arrayItems objectAtIndex:2]];

    
    NSString *otherValue = NULL;
    NSString *strKeyName = @"PLUSDISK";
    NSString *UserID = @"";
    NSString *UseLocalStorage = [arrayItems objectAtIndex:0];
    NSLog(@"%@", UseLocalStorage);
    for (int i = 4; i < arrayItems.count; i++) {
        if(otherValue == NULL){
         if([arrayItems objectAtIndex:i] != NULL || [arrayItems objectAtIndex:i] != @"")
             otherValue = [self encode:[arrayItems objectAtIndex:i] withKey:strkey];   
        }           
        else
        {
            if([arrayItems objectAtIndex:i] != NULL || [arrayItems objectAtIndex:i] != @""){
                 otherValue = [otherValue stringByAppendingString:@"\t"];
                 otherValue = [otherValue stringByAppendingString:[self encode:[arrayItems objectAtIndex:i] withKey:strkey]];
            }
            else
                otherValue = [otherValue stringByAppendingString:@"\t"];
        }
        NSLog(@"%@ is %@", [arrayItems objectAtIndex:i], [self encode:[arrayItems objectAtIndex:i] withKey:strkey]);
        if(i == 9)     UserID = [UserID stringByAppendingString:[arrayItems objectAtIndex:9]];
        //if(i == 12)     UseLocalStorage = [UseLocalStorage stringByAppendingString:[arrayItems objectAtIndex:12]];
    }
    
    g_FileUtil = [FileUtil alloc];
    
	// .tmp 폴더 삭제
	[g_FileUtil deleteFile:[NSString stringWithFormat:@"%@/.tmp", [g_FileUtil getDocumentFolder]]];
    
    // 다른 App에서 데이터 받은 후 서버 업로드 할 때 로그인 체크 ( 로그인 안된 경우 업로드 차단위함 )
    ReceiveDataViewController *receivedatacontroller = [[[ReceiveDataViewController alloc] init] autorelease];
    [receivedatacontroller setLoginFlag:YES SetUserID:UserID];
    
    //로컬스토리지 사용 유무에 따른 사용자 계정별 폴더 생성
    if([UseLocalStorage isEqualToString:@"yes"] ){
        NSString *DocumentFolder = [g_FileUtil getDocumentFolder];
        DocumentFolder = [DocumentFolder stringByAppendingString:@"/Documents/ECM/data/"];
        DocumentFolder = [DocumentFolder stringByAppendingString:UserID];
        if (![g_FileUtil isExist:DocumentFolder]) {
            [g_FileUtil getLocalUserFolder:DocumentFolder];
        }        
    }
    
    NSLog(@"otherValue is %@", otherValue);
    
    NSString *cryptTimeKey = [self encode:strkey withKey:strKeyName];
    cryptTimeKey = [cryptTimeKey stringByAppendingString:@"\t"];
    NSLog(@"cryptTimeKey is %@", cryptTimeKey);
    NSString *cryptPara = [otherValue stringByAppendingString:@"\t"];
    cryptPara = [cryptPara stringByAppendingString:cryptTimeKey];
    NSLog(@"cryptPara is %@", cryptPara);
    NSMutableString *stringToReturn = [NSMutableString stringWithString:cryptPara];
    
    //CDVPluginResult* pluginResult = [pluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[stringToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
     CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
//    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) saveParam:(CDVInvokedUrlCommand *)command{
    [[NSUserDefaults standardUserDefaults] setObject:[command.arguments objectAtIndex:0] forKey:@"param"];
}

//파라미터 암호화
- (void) paramencrypt:(CDVInvokedUrlCommand*)command{
    //self.callbackID = [arguments pop];
//    self.callbackID = [command.arguments objectAtIndex:0];
    self.callbackID = self.callbackID;
    
    NSString *stringObtainedFromJavascript = [command.arguments objectAtIndex:0];
    NSLog(@"stringObtainedFromJavascript is %@", stringObtainedFromJavascript);        
    NSString * ip = [Util getIPAddress];
    NSLog(@"ipaddress is %@", ip);
    stringObtainedFromJavascript = [stringObtainedFromJavascript stringByAppendingString:@"\t"];
    stringObtainedFromJavascript = [stringObtainedFromJavascript stringByAppendingString:ip];
    NSString *strkey = [command.arguments objectAtIndex:1];
    
    NSLog(@"strkey is %@", strkey);
    NSRange range = [stringObtainedFromJavascript rangeOfString:@"CryptUtilPlugin"];
    if( range.location != NSNotFound )
    {
        stringObtainedFromJavascript = [command.arguments objectAtIndex:2];
        NSLog(@"stringObtainedFromJavascript is %@", stringObtainedFromJavascript);  
        strkey = [command.arguments objectAtIndex:2];
        NSLog(@"strkey is %@", strkey);
    }
    NSString * nPass = [Util md5:strkey ];
    
    NSLog(@"stringObtainedFromJavascript2 is %@", stringObtainedFromJavascript);
    
    NSLog(@"nPass is %@", nPass);
    NSArray *arrayItems = [stringObtainedFromJavascript componentsSeparatedByString:@"\t"];
    
    NSString *otherValue = NULL;
    for (int i = 0; i < arrayItems.count; i++) {
        if(otherValue == NULL){
            if([arrayItems objectAtIndex:i] != NULL || [arrayItems objectAtIndex:i] != @"")
                otherValue = [self encode:[arrayItems objectAtIndex:i] withKey:nPass];   
        }           
        else
        {
            if([arrayItems objectAtIndex:i] != NULL || [arrayItems objectAtIndex:i] != @""){
                otherValue = [otherValue stringByAppendingString:@"\t"];
                otherValue = [otherValue stringByAppendingString:[self encode:[arrayItems objectAtIndex:i] withKey:nPass]];
            }
            else
                otherValue = [otherValue stringByAppendingString:@"\t"];
        }
        NSLog(@"%@ is %@", [arrayItems objectAtIndex:i], [self encode:[arrayItems objectAtIndex:i] withKey:nPass]);
        
    }
    
    NSLog(@"otherValue is %@", otherValue);
    NSMutableString *stringToReturn = [NSMutableString stringWithString:otherValue];
    
    //CDVPluginResult* pluginResult = [pluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[stringToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
     CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
    
//    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


// DES 암호화 후 BASE64 인코딩
- (NSString *) encode: (NSString *) str 
			  withKey: (NSString *) key
{
	if (str == nil)
		return nil;
	
	NSString * encoded = [Util doCipher:str key:key action: kCCEncrypt ];
	encoded = [Util urlencode:encoded];
	return encoded;
}

// BASE64 디코딩 후 DES 암호화
- (NSString *) decode: (NSString *) str 
			  withKey: (NSString *) key
{
	if (str == nil)
		return nil;
	
	NSString * decoded = [Util doCipher:str key:key action: kCCDecrypt ];
	return decoded;
}

// 로고 이미지 가져오기
- (void) logoimg:(CDVInvokedUrlCommand*)command{
    //self.callbackID = [arguments pop];
//    self.callbackID = [command.arguments objectAtIndex:0];
    self.callbackID = command.callbackId;
    NSString *Server = [command.arguments objectAtIndex:0];
    NSLog(@"Server is %@", Server);
    NSString *Port = [command.arguments objectAtIndex:1];
    NSLog(@"Port is %@", Port);
    NSString *DomainID = [command.arguments objectAtIndex:2];
    NSLog(@"DomainID is %@", DomainID);

    
    //[self getlogoimg:[NSString objectAtIndex:1]with:[arrayItems objectAtIndex:2]];
    
    [self getlogoimg: Server with: Port with:DomainID];

    
    NSMutableString *stringToReturn = [NSMutableString stringWithString:@""];
    
    //CDVPluginResult* pluginResult = [pluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[stringToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
//    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) getlogoimg: (NSString *) server
                with: (NSString *) port
                with: (NSString *) DomainID
{
    
    NSString *urlStr = NULL;
    
    if ([ DomainID isEqualToString:@"1000000000000"]){
        if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
        {
            urlStr = [NSString stringWithFormat:@"http://%@:%@/webapp/img/mobile_logo.jpg", server, port];
        }
        else{
            urlStr = [NSString stringWithFormat:@"http://%@:%@/webapp/img/tablet_logo.jpg", server, port];
        }
    }
    else{
        if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
        {
            urlStr = [NSString stringWithFormat:@"http://%@:%@/webapp/%@/img/mobile_logo.jpg", server, port, DomainID];
        }
        else{
            urlStr = [NSString stringWithFormat:@"http://%@:%@/webapp/%@/img/tablet_logo.jpg", server, port,DomainID];
        }
    }
   
    
    NSLog(@"urlStr is %@", urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSArray * DocumentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * tmpFolder = [[DocumentDirectories objectAtIndex:0] stringByAppendingPathComponent:@"logo.jpg"];
    NSLog(@"tmpFolder is %@", tmpFolder);
    [data writeToFile:tmpFolder atomically:NO];
}

@end
