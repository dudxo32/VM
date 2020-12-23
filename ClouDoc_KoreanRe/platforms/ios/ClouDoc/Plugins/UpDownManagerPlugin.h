//
//  UpDownManagerPlugin.h
//  CECMPad
//
//  Created by 넷아이디 on 12. 1. 10..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVViewController.h>

#import "ChildBrowserViewController.h"
#import "FolderViewController.h"
#import "CentralECMAppDelegate.h"
#import "ActivityViewController_phone.h"
@interface UpDownManagerPlugin : CDVPlugin {
    NSString* callbackID;
    CentralECMAppDelegate    *appDelegate;
    CDVViewController* cont;
    ActivityViewController* ActView;
    ActivityViewController_phone* ActViewPhone;
}

@property (nonatomic, copy) NSString* callbackID;
@property (nonatomic, retain) CDVViewController *cont;
@property (nonatomic, retain) ActivityViewController *ActView;
@property (nonatomic, retain) ActivityViewController_phone *ActViewPhone;

- (void) download:(CDVInvokedUrlCommand*)command;
- (void) upload:(CDVInvokedUrlCommand*)command;
- (void) setcookie:(CDVInvokedUrlCommand*)command;
@end
