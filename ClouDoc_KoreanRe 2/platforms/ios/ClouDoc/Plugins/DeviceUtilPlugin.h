//
//  DeviceUtilPlugin.h
//  ECM_Tablet
//
//  Created by 넷아이디 on 11. 12. 20..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import <Cordova/CDVPlugin.h>
#import "ChildBrowserViewController.h"

@interface DeviceUtilPlugin : CDVPlugin {
    NSString* callbackID;
    NSString* m_LangID;
}

@property (nonatomic, copy) NSString* callbackID;
@property (nonatomic, copy) NSString* m_LangID;
- (void) LangID:(CDVInvokedUrlCommand*)command;
- (void) Platform:(CDVInvokedUrlCommand*)command;
- (void) progress:(CDVInvokedUrlCommand*)command;
//- (void) Use3G:(CDVInvokedUrlCommand*)command;
- (void) Alert:(CDVInvokedUrlCommand*)command;
- (void) confirm:(CDVInvokedUrlCommand*)command;
- (void) getlocalRoot:(CDVInvokedUrlCommand*)command;
- (void) LogOut:(CDVInvokedUrlCommand*)command;
@end
