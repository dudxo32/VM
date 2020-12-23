//
//  Entertainment.h
//  CECMPad
//
//  Created by 넷아이디 on 12. 7. 16..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import "Util.h"

@interface Entertainment : CDVPlugin
{
    NSString* callbackID;
}

@property (nonatomic, copy) NSString* callbackID;

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker;
- (void) GetPhoto;
- (void) readFile : (CDVInvokedUrlCommand*)command;
- (void) appendBookmark : (CDVInvokedUrlCommand*)command;

@end
