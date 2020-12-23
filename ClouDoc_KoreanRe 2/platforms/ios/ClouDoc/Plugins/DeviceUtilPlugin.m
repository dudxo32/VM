//
//  DeviceUtilPlugin.m
//  ECM_Tablet
//
//  Created by 넷아이디 on 11. 12. 20..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DeviceUtilPlugin.h"

#import "AppDelegate.h"
#import "FileUtil.h"
#import "Macaddress.h"
#import "Util.h"
@implementation DeviceUtilPlugin
@synthesize callbackID, m_LangID;

//LangID 구하는 함수
- (void) LangID:(CDVInvokedUrlCommand*)command{
    [self.commandDelegate runInBackground:^{
    NSLog(@"LangID native");
    //self.callbackID = [arguments pop];
//     self.callbackID = [command.arguments objectAtIndex:0];
    self.callbackID = command.callbackId;
 /*   NSArray	*preferredLangs = [NSLocale preferredLanguages];
    NSLog(@"preferredLang: %@", [preferredLangs objectAtIndex:0]);
    
    if ([[preferredLangs objectAtIndex:0] isEqualToString:@"ko"])
        m_LangID = @"kor";
    else if ([[preferredLangs objectAtIndex:0] isEqualToString:@"ja"])
        m_LangID = @"jpn";
    else if ([[preferredLangs objectAtIndex:0] isEqualToString:@"zh-Hans"])
        m_LangID = @"chn";
    else
        m_LangID = @"eng";
   */
        
    NSArray	*preferredLangs = [NSLocale preferredLanguages];
        NSLog(@"Lang = %@", [preferredLangs objectAtIndex:0]);
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *languageCode = [currentLocale objectForKey:NSLocaleLanguageCode];
    
    if ([languageCode isEqualToString:@"ko"])
        m_LangID = @"kor";
    else if ([languageCode isEqualToString:@"ja"])
        m_LangID = @"jpn";
    else if ([languageCode isEqualToString:@"zh"])
        m_LangID = @"chn";
    else if ([languageCode isEqualToString:@"zh-Hans"])
        m_LangID = @"chn";
    else
        m_LangID = @"eng";
    
    
    m_LangID = @"kor";
//    char* macAddressString= (char*)malloc(18);
//    NSString *macAddress= [[NSString alloc] initWithCString:getMacAddress(macAddressString,"en0")
//                                                   encoding:NSMacOSRomanStringEncoding];
//    NSLog(@" %@ ", macAddress);
//    
//    
//    
//    NSString *udid = [Util md5:macAddress ];
//    
//    NSLog(@" %@ ", udid);
//    
//    NSString *retVal = [m_LangID stringByAppendingString:udid];
    
    NSMutableString *stringToReturn = [NSMutableString stringWithString:m_LangID];
    
    //CDVPluginResult* pluginResult = [pluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[stringToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
    
//    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

// Device Platform return
// IPAd : 11
// Android : 12
// Windows : 13
- (void) Platform:(CDVInvokedUrlCommand*)command{
    [self.commandDelegate runInBackground:^{
    NSLog(@"Platform native");
    //self.callbackID = [arguments pop];
//     self.callbackID = [command.arguments objectAtIndex:0];
    self.callbackID = command.callbackId;
    
    NSString *platform = @"11\t";
    
    char* macAddressString= (char*)malloc(18);
    NSString *macAddress= [[NSString alloc] initWithCString:getMacAddress(macAddressString,"en0")
                                                   encoding:NSMacOSRomanStringEncoding];
    NSLog(@"macAddress = %@ ", macAddress);
    
    
    
    NSString *DeviceID = [Util md5:macAddress ];
    
    NSLog(@"DeviceID = %@ ", DeviceID);
    
//    NSString *retVal = [m_LangID stringByAppendingString:udid];
    
//    NSMutableString *stringToReturn = [NSMutableString stringWithString:retVal];
    
//    NSString *DeviceID = [[UIDevice currentDevice] uniqueIdentifier];
    platform = [platform stringByAppendingString:DeviceID];
    
    NSMutableString *stringToReturn = [NSMutableString stringWithString:platform];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
//    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}


- (void) progress:(CDVInvokedUrlCommand*)command{
//    self.callbackID = [arguments pop];
//     self.callbackID = [command.arguments objectAtIndex:0];
    self.callbackID = command.callbackId;
    /*
    NSMutableString *stringToReturn = [NSMutableString stringWithString:@"11"];
    
    //CDVPluginResult* pluginResult = [pluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[stringToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
   */
    
    //AppDelegate *test = [UIApplication sharedApplication].delegate;
    
    //NSString* status = [NSString stringWithFormat:@"alert('%@')", test.mgmt_filename ];
    
    [self.webView stringByEvaluatingJavaScriptFromString:@""];
}

- (void) Alert:(CDVInvokedUrlCommand*)command{
    //self.callbackID = [arguments pop];
//    self.callbackID = [command.arguments objectAtIndex:0];
    self.callbackID = self.callbackID;
    NSString *stringObtainedFromJavascript = [command.arguments objectAtIndex:0];
    
    NSLog(@"stringObtainedFromJavascript is %@", stringObtainedFromJavascript);
    
    UIAlertView	*av = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(stringObtainedFromJavascript, nil)
                                                 delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                        otherButtonTitles:nil] autorelease];
    
    [av show];
    
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    
//    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) confirm:(CDVInvokedUrlCommand*)command{
//    self.callbackID = [arguments pop];
//    self.callbackID = [command.arguments objectAtIndex:0];
    self.callbackID = self.callbackID;
    NSString *stringObtainedFromJavascript = [command.arguments objectAtIndex:0];
    NSLog(@"stringObtainedFromJavascript is %@", stringObtainedFromJavascript);
    
    UIAlertView	*av = [[UIAlertView alloc] initWithTitle:nil
                        message:stringObtainedFromJavascript
                        delegate:self cancelButtonTitle:nil
                                       otherButtonTitles:@"OK", @"Cancel", nil];
    
    [av show];
    [av release];
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex{
    CDVPluginResult* pluginResult;
    
    if(buttonIndex)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"cancel"];
        //NSLog(@"cancel");
    }
    else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"ok"];
         NSLog(@"ok");
    }
       
    
//    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackID];
}

- (void) getlocalRoot:(CDVInvokedUrlCommand*)command{
    NSLog(@"getlocalRoot");
//    self.callbackID = [command.arguments objectAtIndex:0];
    self.callbackID = self.callbackID;
    
    NSArray * DocumentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * logopath = [[DocumentDirectories objectAtIndex:0] stringByAppendingPathComponent:@"/logo.jpg"];
    
    NSLog(@"logopath is %@", logopath);
    
    FileUtil *m_FileUtil = [FileUtil alloc];
    BOOL checkimg = [m_FileUtil isExist:logopath];
    
    if( !checkimg ){
        if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
        {
             logopath = @"./img/explorer/mobile/defualt_mobile_logo.jpg";
        }
        else{
             logopath = @"./img/explorer/default_logo.jpg";
        }
    }
    
    
    NSMutableString *stringToReturn = [NSMutableString stringWithString:logopath];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
//    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (void) LogOut:(CDVInvokedUrlCommand*)command{
//    self.callbackID = [command.arguments objectAtIndex:0];
    self.callbackID = self.callbackID;
    
    ActivityViewController *receviedata = [[ActivityViewController alloc] init];
    [receviedata setLoginFlag:NO SetUserID:@""];
    [receviedata DRiveInfo:NULL CookieInfo:NULL dstpath:NULL DownFlag:NO];
    NSMutableString *stringToReturn = [NSMutableString stringWithString:@""];
    
    //CDVPluginResult* pluginResult = [pluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[stringToReturn stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:stringToReturn];
//    [self writeJavascript:[pluginResult toSuccessCallbackString:self.callbackID]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) alertCrashLog:(CDVInvokedUrlCommand*)command{
    self.callbackID = self.callbackID;
    
    NSArray *path = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [path objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory: 앱 죽었을 때 로그 찍기
    NSString *fileName = [NSString stringWithFormat:@"%@/textfile.txt",
                          documentDirectory];
    
    NSMutableString *fileStr = [NSMutableString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"%@", fileStr);
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"log"
                                  message:fileStr
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:ok];
    
    [self.viewController presentViewController:alert animated:YES completion:nil];
}

@end
